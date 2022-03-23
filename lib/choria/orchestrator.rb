require 'English'
require 'mcollective'

module Choria
  class Orchestrator
    class Error < StandardError; end
    class DiscoverError < Error; end

    include MCollective::RPC

    attr_reader :logger

    def initialize(logger:)
      @logger = logger

      configfile ||= MCollective::Util.config_file_for_user
      MCollective::Config.instance.loadconfig(configfile)
    end

    def tasks_support
      @tasks_support ||= MCollective::Util::Choria.new.tasks_support
    end

    def run(task, targets: nil, targets_with_classes: nil, verbose: false)
      rpc_client.progress = verbose

      logger.debug "Running task: '#{task.name}' (targets: #{targets.nil? ? 'all' : targets})"
      targets&.each { |target| rpc_client.identity_filter target }

      unless targets_with_classes.nil?
        logger.debug "Filtering targets with classes: #{targets_with_classes}"
        targets_with_classes.each { |klass| rpc_client.class_filter klass }
      end

      logger.wait 'Discovering targets…'
      raise DiscoverError, 'No request sent, no node discovered' if rpc_client.discover.size.zero?

      logger.wait "Downloading task '#{task.name}' on #{rpc_client.discover.size} nodes…"
      rpc_client.download(task: task.name, files: task.files, verbose: verbose)

      responses = []
      logger.wait "Starting task '#{task.name}' on #{rpc_client.discover.size} nodes…"
      rpc_client.run_no_wait(task: task.name, files: task.files, input: task.input.to_json, verbose: verbose) do |response|
        logger.debug "  Response: '#{response}'"
        responses << response
      end

      # TODO: Include stats in logs when logger will be available (see MCollective::RPC#printrpcstats)

      task.rpc_responses = responses
    end

    def validate_rpc_result(result)
      raise Error, "The RPC agent returned an error: #{result[:statusmsg]}" unless (result[:statuscode]).zero?
    end

    def rpc_client
      @rpc_client ||= rpcclient('bolt_tasks', options: rpc_options)
    end

    private

    def rpc_options
      {
        verbose: false,
        disctimeout: nil,
        timeout: 5,
        config: '/etc/choria/client.conf',
        collective: 'mcollective',
        discovery_method: nil,
        discovery_options: [],
        filter: {
          'fact' => [], 'cf_class' => [], 'agent' => [], 'identity' => [], 'compound' => []
        },
        progress_bar: false,
        mcollective_limit_targets: false,
        batch_size: nil,
        batch_sleep_time: 1,
        output_format: :json,
      }
    end
  end
end
