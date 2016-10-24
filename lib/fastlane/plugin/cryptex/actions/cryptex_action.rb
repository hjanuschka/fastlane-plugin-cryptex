module Fastlane
  module Actions
    class CryptexAction < Action
      def self.run(params)
        UI.message("The cryptex plugin is working!")

        params.load_configuration_file("Cryptexfile")

        Cryptex::Runner.new.run(params)
      end

      def self.description
        "Secure Git-Backed Storage"
      end

      def self.authors
        ["Helmut Januschka"]
      end

      def self.available_options
        Cryptex::Options.available_options
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
