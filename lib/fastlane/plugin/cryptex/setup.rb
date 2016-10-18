module Fastlane
  module Cryptex
    class Setup
      def run(path)
        template = File.read("#{Cryptex::ROOT}/assets/CryptexfileTemplate")

        UI.important "Please create a new, private git repository"
        UI.important "to store the certificates and profiles there"
        url = UI.input("URL of the Git Repo: ")

        template.gsub!("[[GIT_URL]]", url)
        File.write(path, template)
        UI.success "Successfully created '#{path}'. You can open the file using a code editor."
      end
    end
  end
end
