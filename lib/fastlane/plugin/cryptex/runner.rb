module Fastlane
module Cryptex
  class Runner
    attr_accessor :changes_to_commit

    def run(params)
      FastlaneCore::PrintTable.print_values(config: params,
                                         hide_keys: [:workspace],
                                             title: "Summary for cryptex #{Cryptex::VERSION}")

      
    end
  end
end
end
