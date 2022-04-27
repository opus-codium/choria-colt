require 'choria/colt/data_structurer'

require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'

module Choria
  class Orchestrator
    class Task
      class Error < Orchestrator::Error; end

      class ResultSet
        attr_reader :results

        def initialize(on_result:)
          @results = []
          @on_result = on_result
        end

        def integrate_rpc_error(rpc_error)
          result = rpc_error[:body]
          result[:sender] = rpc_error[:senderid]
          integrate_result(result)
        end

        def integrate_result(result)
          structured_result = Choria::Colt::DataStructurer.structure(result).with_indifferent_access
          @results << structured_result
          # TODO: Save "last_run.json" results here…
          @on_result&.call(structured_result)
        end
      end

      attr_reader :id, :name, :input, :environment
      attr_accessor :rpc_responses

      def initialize(orchestrator:, id: nil, name: nil, input: {}, environment: 'production')
        @id = id
        @name = name
        @environment = environment
        @orchestrator = orchestrator

        return if @name.nil?

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

      def results
        result_set.results
      end

      def wait # rubocop:disable Metrics/AbcSize
        if @id.nil?
          rpc_responses_ok, rpc_responses_error = rpc_responses.partition { |res| (res[:body][:statuscode]).zero? }
          rpc_responses_error.each do |res|
            logger.error "Task request failed on '#{res[:senderid]}' (RPC error)"
            result_set.integrate_rpc_error(res)
          end

          @pending_targets = rpc_responses_ok.map { |res| res[:senderid] }
          return if @pending_targets.empty?

          task_ids = rpc_responses_ok.map { |res| res[:body][:data][:task_id] }.uniq
          raise NotImplementedError, "Multiple task IDs: #{task_ids}" unless task_ids.count == 1

          @id = task_ids.first
        end

        wait_results
      end

      def on_result(&block)
        @on_result = lambda { |result|
          block.call(result)
        }
      end

      private

      def result_set
        @result_set ||= ResultSet.new(on_result: @on_result)
      end

      def rpc_results=(results)
        pending_results, completed_results = results.partition { |res| res[:data][:exitcode] == -1 }
        @pending_targets ||= pending_results.map { |res| res[:sender] }

        new_results = completed_results.select { |res| @pending_targets.include? res[:sender] }
        new_results.each do |res|
          logger.debug "New result for task ##{@id}: #{res}"
          result_set.integrate_result(res)
          @pending_targets.delete res[:sender]
        end
      end

      def wait_results
        raise 'Task ID is required!' if @id.nil?

        logger.info "Waiting task #{@id} results…"

        @rpc_results = []

        loop do
          self.rpc_results = @orchestrator.rpc_client.task_status(task_id: @id).map(&:results)

          break if terminated?
        end
      end

      def terminated?
        @pending_targets.empty?
      end

      def _metadata
        logger.info 'Downloading task metadata from the Puppet Server…'
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
