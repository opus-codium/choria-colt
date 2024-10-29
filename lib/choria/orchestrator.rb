require 'English'
require 'mcollective'

module Choria
  class Orchestrator
    class Error < StandardError; end
    class DiscoverError < Error; end

    module RpcResponse
      def sender
        self[:senderid]
      end

      def rpc_error?
        !rpc_success?
      end

      def rpc_success?
        [0, 1].include? self[:body][:statuscode]
      end

      def task_id
        self[:body][:data][:task_id]
      end
    end

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
      discover(targets: targets, targets_with_classes: targets_with_classes)
      raise DiscoverError, 'No requests sent, no nodes discovered' if rpc_client.discover.empty?

      task.run
    end

    def discover(targets: nil, targets_with_classes: nil)
      logger.debug "Targets: #{targets.nil? ? 'all' : targets}"
      targets&.each { |target| rpc_client.identity_filter target }

      unless targets_with_classes.nil?
        logger.debug "Filtering targets with classes: #{targets_with_classes}"
        targets_with_classes.each { |klass| rpc_client.class_filter klass }
      end

      logger.info 'Discovering targets…'
      rpc_client.discover
    end

    def rpc_client
      @rpc_client ||= rpcclient('bolt_tasks', options: {})
    end
  end
end
