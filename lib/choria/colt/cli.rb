require 'choria/colt'
require 'choria/colt/cli/formatter'
require 'choria/colt/cli/thor'

require 'json'
require 'tty/logger'

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
               desc: 'Identifies the targets of the command.'
        option :targets_with_classes,
               aliases: ['--targets-with-class', '-C'],
               desc: 'Select the targets which have the specified Puppet classes.'
        def run(*args)
          input = extract_task_parameters_from_args(args)

          raise Thor::Error, 'Task name is required' if args.empty?
          raise Thor::Error, "Too many arguments: #{args}" unless args.count == 1

          raise Thor::Error, 'Flag --targets or --targets-with-class is required' if options['targets'].nil? && options['targets_with_classes'].nil?

          task_name = args.shift

          targets = options['targets']&.split(',')
          targets = nil if options['targets'] == 'all'

          targets_with_classes = options['targets_with_classes']&.split(',')

          results = colt.run_bolt_task task_name, input: input, targets: targets, targets_with_classes: targets_with_classes do |result|
            $stdout.puts formatter.process_result(result)
          end

          File.write 'last_run.json', JSON.pretty_generate(results)
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
        option :environment,
               aliases: ['-E'],
               desc: 'Puppet environment to grab tasks from',
               default: 'production'
        def show(*tasks_names)
          environment = options['environment']
          cache_directory = File.expand_path('.cache/colt/tasks')
          FileUtils.mkdir_p cache_directory
          cache = Cache.new(path: File.join(cache_directory, "#{environment}.yaml"))

          tasks = colt.tasks(environment: environment, cache: cache)

          if tasks_names.empty?
            show_tasks_summary(tasks)
          else
            tasks_names.each { |task_name| show_task_details(task_name, tasks) }
          end
        end

        no_commands do # rubocop:disable Metrics/BlockLength
          def colt
            @colt ||= Choria::Colt.new logger: logger
          end

          def logger
            @logger ||= TTY::Logger.new do |config|
              config.handlers = [
                [:console, { output: $stderr, level: :info }],
                [:stream, { output: File.open('colt-debug.log', 'a'), level: :debug }],
              ]
              config.metadata = %i[date time]
            end
          end

          def formatter
            @formatter ||= Formatter.new(colored: $stdout.tty?)
          end

          def extract_task_parameters_from_args(args)
            parameters = args.grep(/^\w+=/)
            args.reject! { |arg| arg =~ /^\w+=/ }

            parameters.map do |parameter|
              key, value = parameter.split('=', 2)

              # TODO: Convert to boolean only if the expected type of parameter is boolean
              # TODO: Support String to integer convertion
              # TODO: Support @notation from parameter and/or whole input
              value = true if value == 'true'
              value = false if value == 'false'

              [key, value]
            end.to_h
          end

          def show_tasks_summary(tasks)
            tasks.reject! { |_task, metadata| metadata['metadata']['private'] }

            puts <<~OUTPUT
              #{pastel.title 'Tasks'}
              #{tasks.map { |task, metadata| "#{task}#{' ' * (60 - task.size)}#{metadata['metadata']['description']}" }.join("\n").gsub(/^/, '  ')}
            OUTPUT
          end

          def show_task_details(task_name, tasks)
            metadata = tasks[task_name]
            puts <<~OUTPUT
              #{pastel.title "Task: #{task_name}"}
                #{metadata['metadata']['description']}

              #{pastel.title 'Parameters'}
              #{format_task_parameters(metadata['metadata']['parameters']).gsub(/^/, '  ')}
            OUTPUT
          end

          def format_task_parameters(parameters)
            parameters.map do |parameter, metadata|
              <<~OUTPUT
                #{pastel.parameter(parameter)}  #{pastel.parameter_type metadata['type']}
                  #{metadata['description']}
              OUTPUT
            end.join "\n"
          end

          def pastel
            @pastel ||= _pastel
          end

          def _pastel
            pastel = Pastel.new(enabled: $stdout.tty?)
            pastel.alias_color(:title, :cyan)
            pastel.alias_color(:parameter, :yellow)
            pastel.alias_color(:parameter_type, :bright_white)
            pastel
          end
        end
      end

      desc 'tasks', 'Show and run Bolt tasks.'
      subcommand 'tasks', CLI::Tasks
    end
  end
end
