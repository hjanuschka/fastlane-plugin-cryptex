
module Fastlane
  module Cryptex
    ROOT = Pathname.new(File.expand_path('cryptex', __dir__))
    # Return all .rb files inside the "actions" and "helper" directory
    def self.all_classes
      Dir[File.expand_path('**/{actions,helper}/*.rb', File.dirname(__FILE__))]
    end
  end
end

require 'fastlane/plugin/cryptex/options'
require 'fastlane/plugin/cryptex/change_password'
require 'fastlane/plugin/cryptex/version'
require 'fastlane/plugin/cryptex/setup'
require 'fastlane/plugin/cryptex/git_helper'
require 'fastlane/plugin/cryptex/encrypt'
require 'fastlane/plugin/cryptex/runner'
require 'fastlane/plugin/cryptex/commands_generator'

# By default we want to import all available actions and helpers
# A plugin can contain any number of actions and plugins
Fastlane::Cryptex.all_classes.each do |current|
  require current
end
