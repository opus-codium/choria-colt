require 'choria/colt/data_structurer'

module Choria
  class Orchestrator
    class Task
      class Error < Orchestrator::Error; end

      attr_reader :name, :input, :environment, :rpc_results, :results
      attr_accessor :rpc_responses

      def initialize(name, orchestrator:, input: {}, environment: 'production')
        @name = name
        @environment = environment
        @orchestrator = orchestrator
        @input = default_input.merge input

        logger.debug "Task inputs: #{input}"
        validate_inputs
      end

      def metadata
        @metadata ||= _metadata
      end

      def files
        metadata['files'].to_json
      end

      def wait
        rpc_responses_ok, rpc_responses_error = rpc_responses.partition { |res| (res[:body][:statuscode]).zero? }
        rpc_responses_error.each do |res|
          logger.error "Task request failed on '#{res[:senderid]}':\n#{pp res}"
        end

        task_ids = rpc_responses_ok.map { |res| res[:body][:data][:task_id] }.uniq

        raise NotImplementedError, "Multiple task IDs: #{task_ids}" unless task_ids.count == 1

        @id = task_ids.first

        wait_results
      end

      def on_result(&block)
        @on_result = lambda { |result|
          block.call(result)
        }
      end

      private

      def rpc_results=(results)
        (results - @rpc_results).each do |result|
          next unless result[:data][:exitcode] != -1

          logger.debug "New result for task ##{@id}: #{result}"
          structured_result = Choria::Colt::DataStructurer.structure(result)

          @on_result&.call(structured_result)

          @results << structured_result
        end

        @rpc_results = results
      end

      def wait_results
        raise 'Task ID is required!' if @id.nil?

        logger.wait 'Waiting task results…'

        @results = []
        @rpc_results = []

        loop do
          self.rpc_results = @orchestrator.rpc_client.task_status(task_id: @id).map(&:results)

          break if terminated?
        end
      end

      def terminated?
        @rpc_results.each do |result|
          return false if result[:data][:exitcode] == -1
        end

        true
      end

      def _metadata
        logger.wait 'Downloading task metadata from the Puppet Server…'
        @orchestrator.tasks_support.task_metadata(@name, @environment)
      rescue RuntimeError => e
        raise Error, e.message
      end

      def default_input
        parameters_with_defaults = metadata['metadata']['parameters'].reject { |_k, v| v['default'].nil? }
        parameters_with_defaults.transform_values do |meta|
          meta['default']
        end
      end

      def validate_inputs
        ok, reason = @orchestrator.tasks_support.validate_task_inputs(@input, metadata)
        raise Error, reason.sub(/^\n/, '') unless ok
      end

      def logger
        @orchestrator.logger
      end
    end
  end
end
