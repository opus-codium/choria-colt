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

          def statuscode
            self[:statuscode]
          end

          # CLI
          def output
            if dig(:result, :_output).nil?
              JSON.pretty_generate(self[:result]).split("\n")
            else
              dig(:result, :_output)
            end
          end

          def stderr
            dig(:result, :_stderr)
          end
        end

        module FormattedResult
          attr_accessor :pastel

          def host
            if statuscode.zero?
              format_host pastel.bright_green('√ ').to_s
            else
              format_host pastel.bright_red('⨯ ').to_s
            end
          end

          def content
            case statuscode
            when 0
              # 0 	OK
              format_success
            when 1
              # 1 	OK, failed. All the data parsed ok, we have a action matching the request but the requested action could not be completed. 	RPCAborted
              format_error
            else
              # 2 	Unknown action 	UnknownRPCAction
              # 3 	Missing data 	MissingRPCData
              # 4 	Invalid data 	InvalidRPCData
              # 5 	Other error
              format_rpc_error
            end
          end

          def to_s
            [
              host,
              content,
            ].join("\n")
          end

          private

          def stderr_description
            if stderr.nil? || stderr.empty?
              []
            else
              [
                nil,
                pastel.bright_red('stderr:'),
                stderr,
              ]
            end
          end

          def output_description
            if output.nil? || output.empty?
              []
            else
              [
                nil,
                pastel.bright_red('output:'),
                output,
              ]
            end
          end

          def format_duration
            runtime.nil? ? '' : "duration: #{pastel.bright_white format('%.2fs', runtime)}"
          end

          def format_host(headline)
            "#{headline}#{pastel.host(sender).ljust(60, ' ')}#{format_duration}".strip
          end

          def format_success
            headline = "#{pastel.on_green ' '} "
            warning_headline = "#{pastel.on_yellow ' '} "

            [
              output.map { |line| "#{headline}#{line}" },
              stderr_description.flatten.map { |line| "#{warning_headline}#{line}" },
            ].flatten.join("\n")
          end

          def format_error
            error_details = JSON.pretty_generate(dig(:result, :_error, :details)).split "\n"
            error_description = [
              "#{pastel.bright_red dig(:result, :_error, :kind)}: #{pastel.bright_white dig(:result, :_error, :msg)}",
              "  details: #{error_details.shift}",
              error_details.map { |line| "  #{line}" },
            ]

            headline = "#{pastel.on_red ' '} "

            [
              [
                error_description,
                output_description,
                stderr_description,
              ].flatten.map { |line| "#{headline}#{line}" },
            ].flatten.join("\n")
          end

          def format_rpc_error
            headline = "#{pastel.on_red ' '} "

            [
              "#{headline}#{pastel.bright_red "RPC error (#{statuscode})"}: #{pastel.bright_white self[:statusmsg]}",
            ].join("\n")
          end
        end

        attr_reader :pastel

        def initialize(colored:)
          @pastel = Pastel.new(enabled: colored)
          pastel.alias_color(:host, :cyan)
        end

        def format(result)
          result.extend Formatter::Result
          result.extend Formatter::FormattedResult
          result.pastel = pastel
          result
        end
      end
    end
  end
end
