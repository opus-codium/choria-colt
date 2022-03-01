require 'choria/colt'
require 'choria/colt/cli/thor'

require 'json'
require 'logger'

module Choria
  class Colt
    class CLI < Thor
      class Tasks < Thor
        # BOLT: desc 'run <task name> [parameters] {--targets TARGETS | --query QUERY | --rerun FILTER} [options]', 'Run a Bolt task'
        desc 'run <task name> [parameters] --targets TARGETS [options]', 'Run a Bolt task'
        long_desc <<~DESC
          Run a task on the specified targets.

          Parameters take the form parameter=value.
        DESC
        option :targets,
               aliases: ['--target', '-t'],
               desc: 'Identifies the targets of the command.',
               required: true
        def run(*args)
          input = extract_task_parameters_from_args(args)

          raise Thor::Error, 'Task name is required' if args.empty?
          raise Thor::Error, "Too many arguments: #{args}" unless args.count == 1

          task_name = args.shift

          target = options['targets']
          target = nil if options['targets'] == 'all'

          results = colt.run_bolt_task task_name, input: input, target: target
          $stdout.puts JSON.pretty_generate(results)
        rescue Choria::Orchestrator::Error => e
          raise Thor::Error, "#{e.class}: #{e}"
        end

        desc 'show [task name] [options]', 'Show available tasks and task documentation'
        long_desc <<~DESC
          Show available tasks and task documentation.

          Omitting the name of a task will display a list of tasks available
          in the Bolt project.

          Providing the name of a task will display detailed documentation for
          the task, including a list of available parameters.
        DESC
        def show(task_name)
          raise NotImplementedError
        end

        no_commands do
          def colt
            @colt ||= Choria::Colt.new logger: Logger.new($stdout)
          end

          def extract_task_parameters_from_args(args)
            parameters = args.select { |arg| arg =~ /^\w+=/ }
            args.reject! { |arg| arg =~ /^\w+=/ }

            parameters.map do |parameter|
              key, value = parameter.split('=')
              [key, value]
            end.to_h
          end
        end
      end

      desc 'tasks', 'Show and run Bolt tasks.'
      subcommand 'tasks', CLI::Tasks
    end
  end
end
