describe Fastlane::Actions::TrelloAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The trello plugin is working!")

      Fastlane::Actions::TrelloAction.run(nil)
    end
  end
end
