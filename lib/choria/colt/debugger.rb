module Choria
  class Colt
    module Debugger
      class << self
        attr_writer :enabled

        def enabled
          @enabled ||= false
        end

        def root_directory
          'colt-debug'
        end

        # This method is helpful to grab raw content to be used as test fixture
        # To do so, copy the generated result set (ie. directory) in relevant fixture directory (e.g. `spec/fixtures/orchestrator/task/result_sets`)
        def save_file(result_set:, filename:, content:)
          directory = File.join Colt::Debugger.root_directory, result_set
          FileUtils.mkdir_p directory
          path = File.join directory, filename
          File.write(path, content)

          path
        end
      end
    end
  end
end
