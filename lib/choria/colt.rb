# frozen_string_literal: true

require 'choria/colt/cache'
require 'choria/colt/version'
require 'choria/orchestrator'
require 'choria/orchestrator/task'

require 'logger'

module Choria
  class Colt
    class Error < StandardError; end

    attr_reader :logger, :orchestrator

    def initialize(logger: nil)
      @logger = logger

      @orchestrator = Choria::Orchestrator.new logger: @logger
    end

    def run_bolt_task(task_name, input: {}, targets: nil, targets_with_classes: nil, &block)
      logger.debug "Instantiate task '#{task_name}' and validate input"
      task = Choria::Orchestrator::Task.new(name: task_name, input: input, orchestrator: orchestrator)

      task.on_result(&block) if block_given?

      orchestrator.run(task, targets: targets, targets_with_classes: targets_with_classes)
      task.wait
      task.results
    rescue Choria::Orchestrator::Error => e
      logger.error e.message
      raise
    end

    def wait_bolt_task(task_id, &block)
      task = Choria::Orchestrator::Task.new(id: task_id, orchestrator: orchestrator)

      task.on_result(&block) if block_given?

      task.wait
      task.results
    rescue Choria::Orchestrator::Error => e
      logger.error e.message
      raise
    end

    def tasks(environment:, cache: nil)
      tasks_names = orchestrator.tasks_support.tasks(environment).map do |task|
        task['name']
      end

      return tasks_metadata(tasks_names, environment) if cache.nil?

      cached_tasks = cache.load
      return cached_tasks if cache.clean? && cached_tasks.keys.sort == tasks_names.sort

      updated_tasks = tasks_metadata(tasks_names, environment)
      cache.save updated_tasks

      updated_tasks
    end

    private

    def tasks_metadata(tasks, environment)
      logger.info "Fetching metadata for tasks (environment: '#{environment}')"

      tasks.map do |task|
        logger.debug "Fetching metadata for task '#{task}' (environment: '#{environment}')"
        metadata = orchestrator.tasks_support.task_metadata(task, environment)
        [task, metadata]
      end.to_h
    end
  end
end
