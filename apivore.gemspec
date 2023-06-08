# frozen_string_literal: true

$:.push File.expand_path("../lib", __FILE__)
require 'apivore/version'

Gem::Specification.new do |s|
  s.name        = 'apptweak-apivore'
  s.version     = Apivore::VERSION
  s.summary     = "Tests your API against its OpenAPI (Swagger) 2.0 spec"
  s.description = "Tests your rails API using its OpenAPI (Swagger) description of end-points, models, and query parameters."
  s.authors     = ["Charles Horn"]
  s.email       = 'charles.horn@gmail.com'
  s.files       = ['lib/apivore.rb', 'data/swagger_2.0_schema.json', 'data/draft04_schema.json']
  s.files      += Dir['lib/apivore/*.rb']
  s.files      += Dir['data/custom_schemata/*.json']
  s.homepage      = "https://github.com/apptweak/apivore"
  s.licenses    = ['Apache 2.0']

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if s.respond_to?(:metadata)
    s.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/"
    s.metadata["homepage_uri"] = s.homepage
    s.metadata["github_repo"] = s.homepage
    s.metadata["source_code_uri"] = s.homepage
    s.metadata["rubygems_mfa_required"] = "false" # rubocop:disable Gemspec/RequireMFA
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
          "public gem pushes."
  end
  s.add_runtime_dependency 'json-schema', '~> 2.5'
  s.add_runtime_dependency 'rspec', '~> 3'
  s.add_runtime_dependency 'rspec-expectations', '~> 3.1'
  s.add_runtime_dependency 'rspec-mocks', '~> 3.1'
  s.add_runtime_dependency 'hashie', '~> 3.3'
  s.add_development_dependency 'pry', '~> 0'
  s.add_development_dependency 'rake', '~> 10.3'
  s.add_development_dependency 'rspec-rails', '~> 3'
  s.add_development_dependency 'test-unit', '~> 3'

  s.add_runtime_dependency 'actionpack', '>= 5', '< 8'
  s.add_development_dependency 'activesupport', '>= 5', '< 8'
end
