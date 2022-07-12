# frozen_string_literal: true

require 'choria/colt/version'
require 'choria/orchestrator'
require 'choria/orchestrator/task'

require 'logger'

require 'active_support/cache/memory_store'

module Choria
  class Colt
    class Error < StandardError; end

    attr_reader :logger, :orchestrator

    def initialize(logger: nil)
      @logger = logger

      @orchestrator = Choria::Orchestrator.new logger: @logger
    end

    def run_bolt_task(task_name, input: {}, targets: nil, targets_with_classes: nil, environment: 'production', &block)
      logger.debug "Instantiate task '#{task_name}' and validate input"
      task = Choria::Orchestrator::Task.new(name: task_name, input: input, environment: environment, orchestrator: orchestrator)

      task.on_result(&block) if block_given?

      orchestrator.run(task, targets: targets, targets_with_classes: targets_with_classes)
      task.wait
      task.results
    rescue Choria::Orchestrator::Error => e
      logger.error e.message
      raise
    end

    def wait_bolt_task(task_id, targets: nil, targets_with_classes: nil, &block)
      orchestrator.discover(targets: targets, targets_with_classes: targets_with_classes)

      task = Choria::Orchestrator::Task.new(id: task_id, orchestrator: orchestrator)
      task.on_result(&block) if block_given?
      task.wait
      task.results
    rescue Choria::Orchestrator::Error => e
      logger.error e.message
      raise
    end

    def tasks(environment:, cache: nil, force_cache_refresh: false)
      cache ||= ActiveSupport::Cache::MemoryStore.new

      tasks_names = orchestrator.tasks_support.tasks(environment).map do |task|
        task['name']
      end

      tasks_names.map do |task_name|
        metadata = cache.fetch(task_name, force: force_cache_refresh) do
          task_metadata(task_name, environment)
        end
        [task_name, metadata]
      end.to_h
    end

    private

    def task_metadata(name, environment)
      logger.debug "Fetching metadata for task '#{name}' (environment: '#{environment}')"

      orchestrator.tasks_support.task_metadata(name, environment)
    end
  end
end
