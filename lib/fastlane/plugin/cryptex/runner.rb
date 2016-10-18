module Fastlane
  module Cryptex
    class Runner
      attr_accessor :git_changed
      def import_file(params)
        File.write("#{params[:workspace]}/#{params[:key]}.crypt", File.read(File.expand_path(params[:in])))
        @git_changed = true
      end

      def delete_file(params)
        FileUtils.rm_f "#{params[:workspace]}/#{params[:key]}.crypt"
        @git_changed = true
      end

      def export_file(params)
        File.write(File.expand_path(params[:out]), File.read("#{params[:workspace]}/#{params[:key]}.crypt"))
        @git_changed = true
      end

      def nuke_all(params)
        Encrypt.new.iterate(params[:workspace]) do |item|
          FileUtils.rm_f item
        end
        @git_changed = true
      end

      def run(params)
        FastlaneCore::PrintTable.print_values(config: params,
                                           hide_keys: [],
                                               title: "Summary for cryptex #{Cryptex::VERSION}")
        @git_changed = false
        params[:workspace] = GitHelper.clone(params[:git_url], params[:shallow_clone], skip_docs: params[:skip_docs], branch: params[:git_branch])
        @params = params
        if params[:type] == "import"
          import_file(params)
          return
        end
        if params[:type] == "delete"
          delete_file(params)
          return
        end
        if params[:type] == "export"
          export_file(params)
          return
        end
        if params[:type] == "nuke"
          nuke_all(params)
          return
        end
      ensure
        if git_changed
          message = GitHelper.generate_commit_message(params)
          GitHelper.commit_changes(params[:workspace], message, params[:git_url], params[:git_branch])
        end
        GitHelper.clear_changes
      end
    end
  end
end
