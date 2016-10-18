require 'commander'

HighLine.track_eof = false
module Fastlane
module Cryptex
  class CommandsGenerator
    include Commander::Methods
    UI = FastlaneCore::UI

    def self.start
      FastlaneCore::UpdateChecker.start_looking_for_update('cryptex')
      self.new.run
    ensure
      
      FastlaneCore::UpdateChecker.show_update_status('cryptex', Cryptex::VERSION)
    end

    def run
      program :version, Cryptex::VERSION
      program :description, "Cryptex"
      program :help, 'Author', 'Helmut Januschka <helmut@januschka.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'GitHub', 'https://github.com/hjanuschka/fastlane-plugin-cryptex'
      program :help_formatter, :compact

      global_option('--verbose') { $verbose = true }

      FastlaneCore::CommanderGenerator.new.generate(Cryptex::Options.available_options)

      command :run do |c|
        c.syntax = 'cryptex'
        c.description = Cryptex::DESCRIPTION
        c.action do |args, options|
          params = FastlaneCore::Configuration.create(Cryptex::Options.available_options, options.__hash__)
          params.load_configuration_file("Cryptexfile")
          Cryptex::Runner.new.run(params)
        end
      end

      
      command :init do |c|
        c.syntax = 'cryptex init'
        c.description = 'Create the Cryptexfile for you'
        c.action do |args, options|
          containing = (File.directory?("fastlane") ? 'fastlane' : '.')
          path = File.join(containing, "Cryptexfile")

          if File.exist?(path)
            FastlaneCore::UI.user_error!("You already got a Cryptexfile in this directory")
            return 0
          end

          Cryptex::Setup.new.run(path)
        end
      end

      command :change_password do |c|
        c.syntax = 'cryptex change_password'
        c.description = 'Re-encrypt all files with a different password'
        c.action do |args, options|
          puts "CHANGE PASSWORD"
        end
      end

      command :decrypt do |c|
        c.syntax = "cryptex decrypt"
        c.description = "Decrypts the repository and keeps it on the filesystem"
        c.action do |args, options|
          puts "DECRYPT"
        end
      end
      command "nuke" do |c|
        # We have this empty command here, since otherwise the normal `match` command will be executed
        c.syntax = "cryptex nuke"
        c.description = "Delete all Crypted Files in the repository"
        c.action do |args, options|
          puts "NUKE"
        end
      end

      default_command :run

      run!
    end
  end
end
end
