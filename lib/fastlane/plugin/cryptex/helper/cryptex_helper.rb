module Fastlane
  module Helper
    class CryptexHelper
      # class methods that you define here become available in your action
      # as `Helper::CryptexHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the cryptex plugin helper!")
      end
    end
  end
end
