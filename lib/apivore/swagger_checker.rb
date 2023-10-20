module Apivore
  class SwaggerChecker
    PATH_TO_CHECKER_MAP = {}

    def self.instance_for(path, is_local: false)
      PATH_TO_CHECKER_MAP[path] ||= new(path, is_local: is_local)
    end

    def has_path?(path)
      mappings.has_key?(path)
    end

    def has_method_at_path?(path, method)
      mappings[path].has_key?(method)
    end

    def has_response_code_for_path?(path, method, code)
      mappings[path][method].has_key?(code.to_s)
    end

    def response_codes_for_path(path, method)
      mappings[path][method].keys.join(", ")
    end

    def has_matching_document_for(path, method, code, body)
      JSON::Validator.fully_validate(
        swagger, body, fragment: fragment(path, method, code)
      )
    end

    def fragment(path, method, code)
      path_fragment = mappings[path][method.to_s][code.to_s]
      path_fragment.dup unless path_fragment.nil?
    end

    def remove_tested_end_point_response(path, method, code)
      return if untested_mappings[path].nil? ||
        untested_mappings[path][method].nil?
      untested_mappings[path][method].delete(code.to_s)
      if untested_mappings[path][method].size == 0
        untested_mappings[path].delete(method)
        if untested_mappings[path].size == 0
          untested_mappings.delete(path)
        end
      end
    end

    def base_path
      @swagger.base_path
    end

    def response=(response)
      @response = response
    end

    def tested_mappings
      result = {}
      @swagger.each_response do |path, method, response_code, fragment|
        next unless untested_mappings.dig(path, method, response_code).nil?

        result[path] ||= {}
        result[path][method] ||= {}
        result[path][method][response_code] = fragment
      end

      JSON.parse(JSON.generate(result))
    end

    attr_reader :response, :swagger, :swagger_path, :untested_mappings

    private

    attr_reader :mappings, :is_local

    def initialize(swagger_path, is_local: false)
      @swagger_path = swagger_path
      @is_local = is_local
      load_swagger_doc!
      validate_swagger!
      setup_mappings!
    end

    def load_swagger_doc!
      @swagger = Apivore::Swagger.new(fetch_swagger!)
    end

    def fetch_swagger!
      return JSON.parse(File.read(swagger_path)) if is_local

      session = ActionDispatch::Integration::Session.new(Rails.application)
      begin
        session.get(swagger_path)
      rescue
        fail "Unable to perform GET request for swagger json: #{swagger_path} - #{$!}."
      end
       JSON.parse(session.response.body)
    end

    def validate_swagger!
      errors = swagger.validate
      unless errors.empty?
        msg = "The document fails to validate as Swagger #{swagger.version}:\n"
        msg += errors.join("\n")
        fail msg
      end
    end

    def fetch_tested_mappings!
      Dir['tmp/apivore/tested_mappings*.json'].each_with_object({}) do |file, hash|
        hash.deep_merge!(JSON.parse(File.read(file)))
      end
    rescue StandardError
      {}
    end

    def setup_mappings!
      @mappings = {}

      tested_mappings_hash = fetch_tested_mappings!

      @swagger.each_response do |path, method, response_code, fragment|
        @mappings[path] ||= {}
        @mappings[path][method] ||= {}
        raise "duplicate" unless @mappings[path][method][response_code].nil?
        next if tested_mappings_hash.dig(path, method).present? && tested_mappings_hash[path][method].has_key?(response_code)

        @mappings[path][method][response_code] = fragment
      end

      @untested_mappings = JSON.parse(JSON.generate(@mappings))
    end
  end
end
