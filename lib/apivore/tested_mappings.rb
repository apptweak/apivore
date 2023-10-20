module Apivore
  module TestedMappings
    class << self
      def persist(swagger_checker)
        # create a directory if it doesn't exist
        FileUtils.mkdir_p('tmp')
        FileUtils.mkdir_p('tmp/apivore')
        # it writes the JSON inside the tmp/apivore directory
        File.open("tmp/apivore/tested_mappings#{ENV['TEST_ENV_NUMBER']}.json", 'w') do |f|
          f.write(swagger_checker.tested_mappings.to_json)
        end
        true
      rescue StandardError
        false
      end
    end
  end
end
