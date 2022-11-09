require_relative 'task/result_set'

require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'

require 'choria/colt/debugger'

module Choria
  class Orchestrator
    class Task
      class Error < Orchestrator::Error; end
      class NoNodesLeftError < Error; end

      attr_reader :id, :name, :input, :environment

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

      def run
        raise Error, 'Unable to run a task by ID' if name.nil?

        @pending_targets = rpc_client.discover
        _download
        _run_no_wait
      end

      def wait
        raise Error, 'Task ID is required!' if @id.nil?

        logger.info "Waiting task #{@id} results…"
        @rpc_results = []
        loop do
          self.rpc_results = rpc_client.task_status(task_id: @id).map(&:results)
          break if @pending_targets.empty?
        end
      end

      def on_result(&block)
        @on_result = ->(result, count, total_count) { block.call(result, count, total_count) }
      end

      private

      def result_set
        @result_set ||= ResultSet.new(on_result: @on_result)
      end

      def log_new_result(res)
        if Colt::Debugger.enabled
          debug_file = Colt::Debugger.save_file(result_set: @id, filename: "#{Time.now.iso8601}-#{res[:sender]}.json", content: JSON.pretty_generate(res))
          logger.debug "New result for task ##{@id} saved in '#{debug_file}'"
        else
          logger.debug "New result for task ##{@id} from '#{res[:sender]}'"
        end
      end

      def rpc_results=(results)
        completed_results = results.reject { |res| res[:data][:exitcode] == -1 }
        @pending_targets ||= results.map { |res| res[:sender] }

        new_results = completed_results.select { |res| @pending_targets.include? res[:sender] }
        new_results.each do |res|
          log_new_result res

          @pending_targets.delete res[:sender]
          result_set.pending_count = @pending_targets.count
          result_set.integrate_result res
        end
      end

      def process_rpc_response(rpc_response)
        rpc_response.extend Orchestrator::RpcResponse
        logger.debug "  RPC Response: '#{rpc_response}'"
        return unless rpc_response.rpc_error?

        @pending_targets.delete rpc_response.sender
        result_set.integrate_rpc_error(rpc_response)
      end

      def _download
        logger.info "Downloading task '#{name}' on #{rpc_client.discover.size} nodes…"
        rpc_client.download(task: name, files: files, verbose: false) do |rpc_response|
          process_rpc_response(rpc_response)
        end

        raise NoNodesLeftError, "No nodes left to continue after 'download' action" if @pending_targets.empty?
      end

      def _run_no_wait # rubocop:disable Metrics/AbcSize
        logger.info "Starting task '#{name}' on #{rpc_client.discover.size} nodes…"
        task_ids = []
        rpc_client.run_no_wait(task: name, files: files, input: input.to_json, verbose: false) do |rpc_response|
          process_rpc_response(rpc_response)
          task_ids << rpc_response.task_id
        end
        raise NoNodesLeftError, "No nodes left to continue after 'run_no_wait' action" if @pending_targets.empty?

        task_ids.compact!
        task_ids.uniq!
        raise NotImplementedError, "Multiple task IDs: #{task_ids}" unless task_ids.count == 1

        @id = task_ids.first
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

      def rpc_client
        @orchestrator.rpc_client
      end
    end
  end
end
