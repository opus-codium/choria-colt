# frozen_string_literal: true

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

    def run_bolt_task(task_name, input: {}, target: nil, cli: false)
      logger.debug "Instantiate task '#{task_name}' and validate input"
      task = Choria::Orchestrator::Task.new(task_name, input: input, orchestrator: orchestrator)

      orchestrator.run(task, target: target)
      task.wait
      task.results
    rescue Choria::Orchestrator::Error => e
      logger.error e.message
      raise
    end
  end
end
