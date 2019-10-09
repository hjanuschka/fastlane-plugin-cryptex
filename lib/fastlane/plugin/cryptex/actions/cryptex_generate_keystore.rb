module Fastlane
  module Actions
    class CryptexGenerateKeystoreAction < Action
      def self.run(params)
        require "fileutils"
        cmd = "keytool -genkey -v -keystore #{File.expand_path(params[:destination])} -storepass #{params[:password]} -keypass #{params[:password]} -alias #{params[:alias]} -dname 'CN=#{params[:fullname]},L=#{params[:city]}' -validity 10000 -keyalg #{params[:keyalg]}"
        FastlaneCore::CommandExecutor.execute(command: cmd,
                                            print_all: true,
                                        print_command: true)

        params[:destination]
      end

      def self.description
        "Generate a new Android Keystore"
      end

      def self.authors
        ["Helmut Januschka"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "MATCH_KEYSTORE_PASSWORD",
                                       description: "Password for the Keystore",
                                       optional: true,
                                       is_string: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :alias,
                                       env_name: "MATCH_KEYSTORE_ALIAS",
                                       description: "ALIAS for the Keystore",
                                       optional: true,
                                       is_string: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :destination,
                                       env_name: "MATCH_KEYSTORE_DESTINATION",
                                       description: "Where to put decrypted keystore",
                                       optional: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :fullname,
                                       env_name: "MATCH_KEYSTORE_FULLNAME",
                                       description: "Fullname of keystore owner",
                                       optional: true,
                                       is_string: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :city,
                                       env_name: "MATCH_KEYSTORE_CITY",
                                       description: "City of keystore owner",
                                       optional: true,
                                       is_string: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :keyalg,
                                       env_name: "MATCH_KEYSTORE_KEYALG",
                                       description: "Signature algorithm for the Keystore",
                                       optional: true,
                                       is_string: true,
                                       default_value: "RSA"),

        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
