module Fastlane
  module Cryptex
    class Encrypt
      require 'security'
      require 'shellwords'

      def server_name(git_url)
        ["cryptex", git_url].join("_")
      end

      def password(git_url)
        password = ENV["CRYPTEX_PASSWORD"]
        unless password
          item = Security::InternetPassword.find(server: server_name(git_url))
          password = item.password if item
        end

        unless password
          UI.important "Enter the passphrase that should be used to encrypt/decrypt your repository"
          UI.important "This passphrase is specific per repository and will be stored in your local keychain"
          UI.important "Make sure to remember the password, as you'll need it when you run cryptex on a different machine"
          password = ChangePassword.ask_password(confirm: true)
          store_password(git_url, password)
        end

        return password
      end

      def store_password(git_url, password)
        Security::InternetPassword.add(server_name(git_url), "", password)
      end

      # removes the password from the keychain again
      def clear_password(git_url)
        Security::InternetPassword.delete(server: server_name(git_url))
      end

      def encrypt_repo(path: nil, git_url: nil, digest: nil)
        iterate(path) do |current|
          crypt(path: current,
            password: password(git_url),
             encrypt: true,
              digest: digest)
          UI.success "🔒  Encrypted '#{File.basename(current)}'" if $verbose
        end
        UI.success "🔒  Successfully encrypted certificates repo"
      end

      def decrypt_repo(path: nil, git_url: nil, manual_password: nil, digest: nil)
        iterate(path) do |current|
          begin
            crypt(path: current,
              password: manual_password || password(git_url),
               encrypt: false,
                digest: digest)
          rescue StandardError
            UI.error "Couldn't decrypt the repo, please make sure you enter the right password!"
            UI.user_error!("Invalid password passed via 'CRYPTEX_PASSWORD'") if ENV["CRYPTEX_PASSWORD"]
            clear_password(git_url)
            decrypt_repo(path: path, git_url: git_url, digest: digest)
            return
          end
          UI.success "🔓  Decrypted '#{File.basename(current)}'" if $verbose
        end
        UI.success "🔓  Successfully decrypted certificates repo"
      end

      def iterate(source_path)
        Dir[File.join(source_path, "**", "*.{crypt}")].each do |path|
          next if File.directory?(path)
          yield(path)
        end
      end

      private

      def crypt(path: nil, password: nil, encrypt: true, digest: 'sha256')
        if password.to_s.strip.length.zero? && encrypt
          UI.user_error!("No password supplied")
        end

        tmpfile = File.join(Dir.mktmpdir, "temporary")
        command = ["openssl aes-256-cbc"]
        command << "-k #{password.shellescape}"
        command << "-md #{digest}"
        command << "-in #{path.shellescape}"
        command << "-out #{tmpfile.shellescape}"
        command << "-a"
        command << "-d" unless encrypt
        command << "&> /dev/null" unless $verbose # to show show an error message is something goes wrong
        success = system(command.join(' '))

        UI.crash!("Error decrypting '#{path}'") unless success
        FileUtils.mv(tmpfile, path)
      end
    end
  end
end
