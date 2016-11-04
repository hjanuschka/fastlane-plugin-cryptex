module Fastlane
  describe Fastlane::Actions::CryptexAction do
    describe '#run' do
      it 'prints a message' do
        #      expect(Fastlane::UI).to receive(:message).with("The cryptex plugin is working!")
        values = {
          git_url: "/tmp/123"

        }
        config = FastlaneCore::Configuration.create(Cryptex::Options.available_options, values)
        #      Fastlane::Actions::CryptexAction.run(config)
      end
    end
  end
end
