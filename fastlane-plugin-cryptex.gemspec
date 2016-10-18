# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/cryptex/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-cryptex'
  spec.version       = Fastlane::Cryptex::VERSION
  spec.author        = %q{Helmut Januschka}
  spec.email         = %q{h.januschka@krone.at}

  spec.summary       = %q{fastlane Crypt Store Git repo}
  # spec.homepage      = "https://github.com/<GITHUB_USERNAME>/fastlane-plugin-cryptex"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(bin/cryptex README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }


  # spec.add_dependency 'your-dependency', '~> 1.0.0'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 1.105.2'
end
