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
        it 'format a successful result' do
          expect(formatter.process_result(rpc_result)).to eq(
            <<~OUTPUT.chomp
              vm012345.example.com
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
  end
end
