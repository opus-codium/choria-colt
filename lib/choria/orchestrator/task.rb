require 'choria/colt/data_structurer'

module Choria
  class Orchestrator
    class Task
      class Error < Orchestrator::Error; end

      attr_reader :name, :input, :environment, :rpc_results
      attr_accessor :rpc_responses

      def initialize(name, orchestrator:, input: {}, environment: 'production')
        @name = name
        @input = input
        @environment = environment
        @orchestrator = orchestrator

        validate_inputs
      end

      def metadata
        @metadata ||= _metadata
      end

      def files
        metadata['files'].to_json
      end

      def wait
        task_ids = rpc_responses.map { |res| res[:body][:data][:task_id] }.uniq
        raise NotImplementedError, "Multiple task IDs: #{task_ids}" unless task_ids.count == 1

        @rpc_results = @orchestrator.wait_results task_id: task_ids.first
      end

      def results
        Choria::Colt::DataStructurer.structure(@rpc_results)
      end

      private

      def _metadata
        # puts 'Retrieving task metadata for task %s from the Puppet Server' % task if verbose
        @orchestrator.tasks_support.task_metadata(@name, @environment)
      rescue RuntimeError => e
        raise Error, e.message
      end

      def validate_inputs
        ok, reason = @orchestrator.tasks_support.validate_task_inputs(@input, metadata)
        raise Error, reason.sub(/^\n/, '') unless ok
      end
    end
  end
end
