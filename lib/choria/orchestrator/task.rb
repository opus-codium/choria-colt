module Choria
  class Orchestrator
    class Task
      class Error < Orchestrator::Error; end

      attr_reader :name, :input, :environment, :rpc_results
      attr_accessor :rpc_response

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
        @rpc_results = @orchestrator.wait_results task_id: rpc_response[:body][:data][:task_id]
      end

      def results
        @rpc_results.map do |res|
          raise NotImplementedError, 'What to do when res[:data][:stderr] contains something?' unless res[:data][:stderr].empty?

          res[:result] = JSON.parse res[:data][:stdout]
          res[:data].delete :stderr
          res[:data].delete :stdout
          res
        end
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
