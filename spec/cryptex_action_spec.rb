describe Fastlane::Actions::CryptexAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The cryptex plugin is working!")

      Fastlane::Actions::CryptexAction.run(nil)
    end
  end
end
