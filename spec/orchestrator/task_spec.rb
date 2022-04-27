require 'choria/orchestrator'
require 'choria/orchestrator/task'

require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'

def load_from_rpc_results_file(file)
  JSON.parse(File.read(File.join(__dir__, '..', 'fixtures/orchestrator/task/rpc_results', "#{file}.json"))).map(&:with_indifferent_access)
end

def load_from_rpc_responses_file(file)
  JSON.parse(File.read(File.join(__dir__, '..', 'fixtures/orchestrator/task/rpc_responses', "#{file}.json"))).map(&:with_indifferent_access)
end

RSpec.describe Choria::Orchestrator::Task do
  rpc_results_files = [
    '2022-04-07_15:08:40.968',
    '2022-04-07_15:08:42.286',
    '2022-04-07_15:08:43.640',
    '2022-04-07_15:08:43.646',
  ]
  let(:tasks_support) do
    tasks_support = double('tasks_support')
    allow(tasks_support).to receive(:validate_task_inputs) { [true, ''] }
    allow(tasks_support).to receive(:task_metadata) do
      {
        'metadata' => {
          'parameters' => {},
        },
      }
    end
    tasks_support
  end

  let(:orchestrator) do
    orchestrator = double('orchestrator')
    allow(orchestrator).to receive(:tasks_support) { tasks_support }
    allow(orchestrator).to receive(:logger) { Logger.new '/dev/null' }
    orchestrator
  end

  let(:task) { Choria::Orchestrator::Task.new(name: 'example', orchestrator: orchestrator) }

  context 'waiting the rpc results targeting 4 nodes' do
    let(:rpc_results) do
      rpc_results_files.map { |file| load_from_rpc_results_file file }
    end

    let(:dummy) { double('dummy') }

    it 'processes first result, all are running' do
      task.on_result { dummy.on_result }
      expect(dummy).to receive(:on_result).exactly(0).times
      task.send(:rpc_results=, rpc_results.shift)
    end

    it 'processes two first results, 3 targets are done' do
      task.on_result { dummy.on_result }
      expect(dummy).to receive(:on_result).exactly(3).times
      2.times { task.send(:rpc_results=, rpc_results.shift) }
    end

    it 'processes three first results, 4 targets are done' do
      task.on_result { dummy.on_result }
      expect(dummy).to receive(:on_result).exactly(4).times
      3.times { task.send(:rpc_results=, rpc_results.shift) }
    end

    it 'processes four first results, 4 targets are done' do
      task.on_result { dummy.on_result }
      expect(dummy).to receive(:on_result).exactly(4).times
      4.times { task.send(:rpc_results=, rpc_results.shift) }
    end
  end

  context 'receiving rpc errors during #wait' do
    let(:dummy) { double('dummy') }

    it 'produces #results with errors' do
      task.on_result { dummy.on_result }
      expect(dummy).to receive(:on_result).exactly(8).times
      task.rpc_responses = load_from_rpc_responses_file 'errors'
      task.wait
    end
  end
end
