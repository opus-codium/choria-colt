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

          targets = options['targets'].split ','
          targets = nil if options['targets'] == 'all'

          results = colt.run_bolt_task task_name, input: input, targets: targets

          File.write 'last_run.json', JSON.pretty_generate(results)

          show_results(results)
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

        no_commands do
          def colt
            @colt ||= Choria::Colt.new logger: Logger.new($stdout)
          end

          def extract_task_parameters_from_args(args)
            parameters = args.grep(/^\w+=/)
            args.reject! { |arg| arg =~ /^\w+=/ }

            parameters.map do |parameter|
              key, value = parameter.split('=')
              [key, value]
            end.to_h
          end

          def show_tasks_summary(tasks)
            tasks.reject! { |_task, metadata| metadata['metadata']['private'] }

            puts <<~OUTPUT
              Tasks
              #{tasks.map { |task, metadata| "#{task}#{' ' * (60 - task.size)}#{metadata['metadata']['description']}" }.join("\n").gsub(/^/, '  ')}
            OUTPUT
          end

          def show_task_details(task_name, tasks)
            metadata = tasks[task_name]
            puts <<~OUTPUT
              Task: '#{task_name}'
                #{metadata['metadata']['description']}

              Parameters:
              #{JSON.pretty_generate(metadata['metadata']['parameters']).gsub(/^/, '  ')}
            OUTPUT
          end

          def show_results(results)
            results.each { |result| show_result(result) }
          end

          def show_result(result)
            return show_generic_output(result) unless result.dig(:result, '_output').nil? || (result.dig(:result, 'exit_code') != 0)

            $stdout.puts JSON.pretty_generate(result)
          end

          def show_generic_output(result)
            target = result[:sender]

            output = result.dig(:result, '_output')
            $stdout.puts "'#{target}':"
            output.each { |line| $stdout.puts("  #{line}") }
          end
        end
      end

      desc 'tasks', 'Show and run Bolt tasks.'
      subcommand 'tasks', CLI::Tasks
    end
  end
end
