require 'choria/colt/cli'
require 'choria/colt/cli/thor'

module Choria
  class Colt
    class CLI < Thor
      class Formatter
        module Result
          def sender
            self[:sender]
          end

          def exitcode
            dig(:data, :exitcode)
          end

          def ok?
            exitcode&.zero?
          end

          def runtime
            dig(:data, :runtime)
          end

          # CLI
          def output
            if dig(:result, :_output).nil?
              JSON.pretty_generate(self[:result]).split("\n")
            else
              dig(:result, :_output)
            end
          end
        end

        attr_reader :pastel

        def initialize(colored:)
          @pastel = Pastel.new(enabled: colored)
          pastel.alias_color(:host, :cyan)
        end

        def process_result(result)
          result.extend Formatter::Result
          return process_error(result) unless result.ok?

          process_success(result)
        end

        def process_success(result)
          host = format_host(result, "#{pastel.bright_green '√'} ")
          headline = "#{pastel.on_green ' '} "

          [
            host,
            result.output.map { |line| "#{headline}#{line}" },
          ].flatten.join("\n")
        end

        def process_error(result) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          host = format_host(result, "#{pastel.bright_red '⨯'} ")
          output = result.dig(:result, '_output')
          error_details = JSON.pretty_generate(result.dig(:result, :_error, :details)).split "\n"
          error_description = [
            "#{pastel.bright_red result.dig(:result, :_error, :kind)}: #{pastel.bright_white result.dig(:result, :_error, :msg)}",
            "  details: #{error_details.shift}",
            error_details.map { |line| "  #{line}" },
          ]
          output_description = if output.nil? || output.empty?
                                 []
                               else
                                 [
                                   nil,
                                   pastel.bright_red('output:'),
                                   output,
                                 ]
                               end

          headline = "#{pastel.on_red ' '} "

          [
            host,
            [
              error_description,
              output_description,
            ].flatten.map { |line| "#{headline}#{line}" },
          ].flatten.join("\n")
        end

        private

        def format_duration(result)
          result.runtime.nil? ? '' : "duration: #{pastel.bright_white format('%.2fs', result.runtime)}"
        end

        def format_host(result, headline)
          "#{headline}#{pastel.host(result.sender).ljust(60, ' ')}#{format_duration(result)}"
        end
      end
    end
  end
end
