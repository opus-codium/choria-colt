require 'choria/colt/cli/formatter'

require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'

RSpec.describe Choria::Colt::CLI::Formatter do
  let(:formatter) { Choria::Colt::CLI::Formatter.new(colored: false) }

  let(:result_set) do
    directory = result_set_name
    result_set = Choria::Orchestrator::Task::ResultSet.new on_result: nil

    path = File.join(__dir__, '..', 'fixtures', 'orchestrator', 'task', 'result_sets', directory)
    Dir.glob("#{path}/*.json") do |filename|
      result_set.integrate_result JSON.parse(File.read(filename)).with_indifferent_access
    end

    result_set
  end

  let(:first_result) { result_set.results.first }

  context 'using the result of `exec` task run' do
    context 'when command ran successfully with output' do
      # "/bin/true --version"
      let(:result_set_name) { 'exec__bin_true__version' }

      describe '#format formats the result' do
        it 'formats a successful result' do
          expect(formatter.format(first_result).to_s).to eq(
            <<~OUTPUT.chomp
              √ vm001.example.com                                           duration: 0.14s
                true (GNU coreutils) 8.32
                Copyright (C) 2020 Free Software Foundation, Inc.
                License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
                This is free software: you are free to change and redistribute it.
                There is NO WARRANTY, to the extent permitted by law.
              #{'  '}
                Written by Jim Meyering.
            OUTPUT
          )
        end
      end
    end

    context 'when command ran with error with output' do
      # "/bin/false --version"
      let(:result_set_name) { 'exec__bin_false__version' }

      describe '#format formats the result' do
        it 'format an error result' do
          expect(formatter.format(first_result).to_s).to eq(
            # rubocop:disable Layout/TrailingWhitespace
            <<~OUTPUT.chomp
              ⨯ vm001.example.com                                           duration: 0.17s
                choria.tasks/task-error: The task errored with a code 1
                  details: {
                    "exitcode": 1
                  }
                
                output:
                false (GNU coreutils) 8.32
                Copyright (C) 2020 Free Software Foundation, Inc.
                License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
                This is free software: you are free to change and redistribute it.
                There is NO WARRANTY, to the extent permitted by law.
              #{'  '}
                Written by Jim Meyering.
            OUTPUT
            # rubocop:enable Layout/TrailingWhitespace
          )
        end
      end
    end


    context 'when executing an invalid command' do
      # "/bin/invalid_command"
      let(:result_set_name) { 'exec__invalid_command' }

      it 'format an error result' do
        expect(formatter.format(first_result).to_s).to eq(
          <<~OUTPUT.chomp
            ⨯ vm001.example.com                                           duration: 0.14s
              choria.tasks/task-error: The task errored with a code 1
                details: {
                  "exitcode": 1
                }
            #{'  '}
              stderr:
              /opt/puppetlabs/puppet/lib/ruby/2.7.0/open3.rb:213:in `spawn': No such file or directory - /bin/invalid_command (Errno::ENOENT)
              	from /opt/puppetlabs/puppet/lib/ruby/2.7.0/open3.rb:213:in `popen_run'
              	from /opt/puppetlabs/puppet/lib/ruby/2.7.0/open3.rb:159:in `popen2'
              	from /opt/puppetlabs/mcollective/tasks-spool/680f0cfb902f5e728fb1ab9bd3c539a2/files/exec/tasks/init.rb:16:in `get2'
              	from /opt/puppetlabs/mcollective/tasks-spool/680f0cfb902f5e728fb1ab9bd3c539a2/files/exec/tasks/init.rb:37:in `<main>'
          OUTPUT
        )
        end
    end

    context 'when RPC failed with error' do
      let(:result_set_name) { 'rpc_error' }

      describe '#format formats the result' do
        it 'format an error result' do
          expect(formatter.format(first_result).to_s).to eq(
            <<~OUTPUT.chomp
              ⨯ vm001.example.com
                RPC error (5): Task exec is not available or does not match the specification, please download it
            OUTPUT
          )
        end
      end
    end

    context 'with a response which contains an error with stdout and stderr' do
      let(:result_set_name) { 'error_with_stdout_and_stderr' }

      it 'formats an error result' do
        res = formatter.format(result_set.results.first).to_s
        expect(res).to eq(
          <<~OUTPUT.chomp
            ⨯ vm001.example.com                                           duration: 0.06s
              choria.tasks/task-error: The task errored with a code 1
                details: {
                  "exitcode": 1
                }
            #{'  '}
              stderr:
              /opt/puppetlabs/mcollective/tasks-spool/232ec40bf86156d2926ef0f7ab304e72/files/nextcloud/tasks/upgrade.rb:6:in `require_relative': cannot load such file -- /opt/puppetlabs/mcollective/tasks-spool/232ec40bf86156d2926ef0f7ab304e72/files/nextcloud/tasks/utils/application_factory (LoadError)
              	from /opt/puppetlabs/mcollective/tasks-spool/232ec40bf86156d2926ef0f7ab304e72/files/nextcloud/tasks/upgrade.rb:6:in `<main>'
          OUTPUT
        )
      end
    end
  end

  context 'with a response which contains a success with stdout and stderr' do
    let(:result_set_name) { 'success_with_stdout_and_stderr' }
    it 'formats an error result' do
      res = formatter.format(result_set.results.first).to_s
      expect(res).to eq(
        <<~OUTPUT.chomp
          √ vm001.example.com                                           duration: 160.98s
            Maintenance mode enabled
            Setting log level to debug
            Updating database schema
            Updated database
            Starting code integrity check...
            Finished code integrity check
            Update successful
            Maintenance mode is kept active
            Resetting log level
            Maintenance mode disabled
            .htaccess has been updated
          #{'  '}
            stderr:
            Nextcloud or one of the apps require upgrade - only a limited number of commands are available
            You may use your browser or the occ upgrade command to do the upgrade
        OUTPUT
      )
    end
  end
end
