module Fastlane
  module Cryptex
    class GitHelper
      def self.clone(git_url, shallow_clone, manual_password: nil, skip_docs: false, branch: "master", digest: nil)
        return @dir if @dir

        @dir = Dir.mktmpdir

        command = "git clone '#{git_url}' '#{@dir}'"
        command << " --depth 1" if shallow_clone

        UI.message "Cloning remote git repo..."
        begin
          FastlaneCore::CommandExecutor.execute(command: "GIT_TERMINAL_PROMPT=0 #{command}",
                                              print_all: $verbose,
                                          print_command: $verbose)
        rescue
          UI.error("Error cloning Repo")
          UI.error("Run the following command manually to make sure you're properly authenticated:")
          UI.command(command)
          UI.user_error!("Error cloning cryptex git repo, please make sure you have access to the repository - see instructions above")
        end

        UI.user_error!("Error cloning repo, make sure you have access to it '#{git_url}'") unless File.directory?(@dir)

        checkout_branch(branch) unless branch == "master"

        copy_readme(@dir) unless skip_docs
        Cryptex::Encrypt.new.decrypt_repo(path: @dir, git_url: git_url, manual_password: manual_password, digest: digest)

        return @dir
      end

      def self.generate_commit_message(params)
        # 'Automatic commit via fastlane'
        [
          "[fastlane]",
          "Updated"
        ].join(" ")
      end

      def self.cryptex_version(workspace)
        path = File.join(workspace, "cryptex_version.txt")
        if File.exist?(path)
          Gem::Version.new(File.read(path))
        end
      end

      def self.commit_changes(path, message, git_url, branch = "master", digest: nil)
        Dir.chdir(path) do
          return if `git status`.include?("nothing to commit")

          Cryptex::Encrypt.new.encrypt_repo(path: path, git_url: git_url, digest: digest)
          File.write("cryptex_version.txt", Cryptex::VERSION) # unencrypted

          commands = []
          commands << "git add -A"
          commands << "git commit -m #{message.shellescape}"
          commands << "GIT_TERMINAL_PROMPT=0 git push origin #{branch.shellescape}"

          UI.message "Pushing changes to remote git repo..."

          commands.each do |command|
            FastlaneCore::CommandExecutor.execute(command: command,
                                                print_all: $verbose,
                                            print_command: $verbose)
          end
        end
        FileUtils.rm_rf(path)
        @dir = nil
      rescue => ex
        UI.error("Couldn't commit or push changes back to git...")
        UI.error(ex)
      end

      def self.clear_changes
        return unless @dir

        FileUtils.rm_rf(@dir)
        UI.success "🔒  Successfully encrypted certificates repo" # so the user is happy
        @dir = nil
      end

      # Create and checkout an specific branch in the git repo
      def self.checkout_branch(branch)
        return unless @dir

        commands = []
        if branch_exists?(branch)
          # Checkout the branch if it already exists
          commands << "git checkout #{branch.shellescape}"
        else
          # If a new branch is being created, we create it as an 'orphan' to not inherit changes from the master branch.
          commands << "git checkout --orphan #{branch.shellescape}"
          # We also need to reset the working directory to not transfer any uncommitted changes to the new branch.
          commands << "git reset --hard"
        end

        UI.message "Checking out branch #{branch}..."

        Dir.chdir(@dir) do
          commands.each do |command|
            FastlaneCore::CommandExecutor.execute(command: command,
                                                  print_all: $verbose,
                                                  print_command: $verbose)
          end
        end
      end

      # Checks if a specific branch exists in the git repo
      def self.branch_exists?(branch)
        return unless @dir

        result = Dir.chdir(@dir) do
          FastlaneCore::CommandExecutor.execute(command: "git branch --list origin/#{branch.shellescape} --no-color -r",
                                                print_all: $verbose,
                                                print_command: $verbose)
        end
        return !result.empty?
      end

      # Copies the README.md into the git repo
      def self.copy_readme(directory)
        template = File.read("#{Cryptex::ROOT}/assets/READMETemplate.md")
        File.write(File.join(directory, "README.md"), template)
      end
    end
  end
end
