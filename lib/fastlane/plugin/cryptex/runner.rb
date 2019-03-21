module Fastlane
  module Cryptex
    class Runner
      attr_accessor :git_changed

      def import_env(params)
        UI.user_error!("No input hash supplied") if params[:hash].to_s.length.zero?
        UI.user_error!("No key file supplied") if params[:key].to_s.length.zero?

        env_world_file = "#{params[:workspace]}/#{params[:key]}_env_world.crypt"
        if params[:hash].kind_of?(String)
          begin
            params[:hash] = JSON.parse(params[:hash])
          rescue StandardError
            # might contain sensitive informatio
            UI.user_error!("Supplied :hash isn't in json format")
          end
        end
        if params[:hash].kind_of?(Hash)
          json = params[:hash].to_json
        else
          UI.user_error!("Not really sure what to do with :hash param of type #{params[:hash].class}")
        end
        File.write(env_world_file, json)
        @git_changed = true
      end

      def export_env(params)
        UI.user_error!("No key file supplied") if params[:key].to_s.length.zero?
        env_world_file = "#{params[:workspace]}/#{params[:key]}_env_world.crypt"
        UI.user_error!("Wrong key file supplied.") unless File.exist? env_world_file

        world_data = File.read(env_world_file)
        world_data_parsed = JSON.parse(world_data)
        ret_json = {}

        world_data_parsed.keys.each do |el|
          next unless !params[:hash] || (params[:hash] && params[:hash].keys.include?(el))
          ret_json[el] = world_data_parsed[el]
          if params[:set_env]
            ENV[el] = world_data_parsed[el]
          end
        end
        return world_data_parsed
      end

      def import_file(params)
        UI.user_error!("No input file supplied") if params[:in].to_s.length.zero?
        in_path = File.expand_path(params[:in])
        UI.user_error!("File to import at `#{in_path}` not found") unless File.exist? in_path

        file = params[:key] unless params[:key].to_s.length.zero?
        file ||= File.basename(params[:in])
        
        require "fileutils"
        
        FileUtils.mkdir_p(File.dirname("#{params[:workspace]}/#{file}"))
        File.write("#{params[:workspace]}/#{file}.crypt", File.read(in_path))
        @git_changed = true
      end

      def delete_file(params)
        UI.user_error!("No key file supplied") if params[:key].to_s.length.zero?
        path = "#{params[:workspace]}/#{params[:key]}.crypt"
        UI.user_error!("Wrong key file supplied.") unless File.exist? path

        FileUtils.rm path
        @git_changed = true
      end

      def export_file(params)
        UI.user_error!("No key file supplied") if params[:key].to_s.length.zero?
        path = "#{params[:workspace]}/#{params[:key]}.crypt"
        UI.user_error!("Wrong key file supplied.") unless File.exist? path

        outfile = params[:out] unless params[:out].to_s.length.zero?
        outfile ||= File.basename(params[:key])
        outfile = File.expand_path(outfile)
        
        require "fileutils"
        
        FileUtils.mkdir_p(File.dirname(outfile))
        File.write(outfile, File.read(path))
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
        params[:workspace] = GitHelper.clone(params[:git_url], params[:shallow_clone], skip_docs: params[:skip_docs], branch: params[:git_branch], digest: params[:digest])
        @params = params
        if params[:type] == "import_env"
          return import_env(params)
        end
        if params[:type] == "export_env"
          return export_env(params)
        end
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
          GitHelper.commit_changes(params[:workspace], message, params[:git_url], params[:git_branch], digest: params[:digest])
        end
        GitHelper.clear_changes
      end
    end
  end
end
