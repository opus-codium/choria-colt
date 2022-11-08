require 'choria/colt/cli/formatter'

require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'

def load_from_result_file(file)
  JSON.parse(File.read(File.join(__dir__, '..', 'fixtures', "#{file}.json"))).first.with_indifferent_access
end

RSpec.describe Choria::Colt::CLI::Formatter do
  let(:formatter) { Choria::Colt::CLI::Formatter.new(colored: false) }

  context 'using the result of `exec` task run' do
    context 'when command ran successfully with output' do
      # "/bin/true --version"
      let(:rpc_result) { load_from_result_file 'bin_true__version' }
      describe '#process_result' do
        it 'formats a successful result' do
          expect(formatter.format(rpc_result).to_s).to eq(
            <<~OUTPUT.chomp
              √ vm012345.example.com                                        duration: 0.08s
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
      let(:rpc_result) { load_from_result_file 'bin_false__version' }
      describe '#process_result' do
        it 'format an error result' do
          expect(formatter.format(rpc_result).to_s).to eq(
            # rubocop:disable Layout/TrailingWhitespace
            <<~OUTPUT.chomp
              ⨯ vm012345.example.com                                        duration: 0.17s
                choria.tasks/task-error: The task errored with a code 1
                  details: {
                    "exitcode": 1
                  }
                
                output:
                false (GNU coreutils) 8.30
                Copyright (C) 2018 Free Software Foundation, Inc.
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

    context 'when RPC failed with error' do
      let(:rpc_result) { load_from_result_file 'rpc_error' }
      describe '#process_result' do
        it 'format an error result' do
          expect(formatter.format(rpc_result).to_s).to eq(
            <<~OUTPUT.chomp
              ⨯ vm012345.example.com
                RPC error (5): Task exec is not available or does not match the specification, please download it
            OUTPUT
          )
        end
      end
    end
  end
end
