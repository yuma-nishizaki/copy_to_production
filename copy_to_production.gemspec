# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'copy_to_production/version'

Gem::Specification.new do |spec|
  spec.name          = "copy_to_production"
  spec.version       = CopyToProduction::VERSION
  spec.authors       = ["Yuma Nishizaki"]
  spec.email         = ["yuma.nishizaki@gmail.com"]

  spec.summary       = %q{A data copy library for rails from staging to production }
  spec.description   = %q{You can copy data from rails staging environment to production. You can even copy 'Papercliped' model with its attachments.}
  spec.homepage      = "https://github.com/yuma-nishizaki/copy_to_production"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "paperclip"  
  spec.add_development_dependency 'rails', '>= 4.0.0'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.1.0'
  spec.add_development_dependency "rails-erd"
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'railroady'
  spec.add_development_dependency 'rspec-activemodel-mocks'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'pg'  
  spec.add_development_dependency "factory_girl_rails", "~> 4.0"
  spec.add_development_dependency "sqlite3"
end
