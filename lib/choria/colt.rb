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

    def run_bolt_task(task_name, input: {}, targets: nil)
      logger.debug "Instantiate task '#{task_name}' and validate input"
      task = Choria::Orchestrator::Task.new(task_name, input: input, orchestrator: orchestrator)

      orchestrator.run(task, targets: targets)
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

      def tasks_metadata(tasks, environment)
        tasks.map do |task|
          logger.debug "Fetching metadata for task '#{task}' (environment: '#{environment}')"
          metadata = orchestrator.tasks_support.task_metadata(task, environment)
          [task, metadata]
        end.to_h
      end

      return tasks_metadata(tasks_names, environment) if cache.nil?

      cached_tasks = cache.load
      return cached_tasks if cache.clean? && cached_tasks.keys.sort == tasks_names.sort

      updated_tasks = tasks_metadata(tasks_names, environment)
      cache.save updated_tasks

      updated_tasks
    end
  end
end
