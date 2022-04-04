require 'choria/colt/cli'
require 'choria/colt/cli/thor'

module Choria
  class Colt
    class CLI < Thor
      class Formatter
        attr_reader :pastel

        def initialize(colored:)
          @pastel = Pastel.new(enabled: colored)
          pastel.alias_color(:host, :cyan)
        end

        def process_result(result)
          return process_error(result) unless result.dig(:data, :exitcode)&.zero?

          process_success(result)
        end

        def process_success(result)
          if result.dig(:result, '_output').nil?
            [
              pastel.host(result[:sender]).to_s,
              JSON.pretty_generate(result[:result]).split("\n").map { |line| "  #{line}" },
            ].join("\n")
          else
            [
              pastel.host(result[:sender]).to_s,
              result.dig(:result, '_output').map { |line| "  #{line}" },
            ].join("\n")
          end
        end

        def process_error(result) # rubocop:disable Metrics/AbcSize
          host = "#{pastel.bright_red '⨯'} #{pastel.host(result[:sender])}"
          output = result.dig(:result, '_output')
          error_details = JSON.pretty_generate(result.dig(:result, :_error, :details)).split "\n"
          error_desc = [
            "#{pastel.bright_red result.dig(:result, :_error, :kind)}: #{pastel.bright_white result.dig(:result, :_error, :msg)}",
            "  details: #{error_details.shift}",
            error_details.map { |line| "  #{line}" },
          ]

          headline = "#{pastel.on_red ' '} "

          [
            host,
            [
              error_desc,
              nil,
              pastel.bright_red('output:'),
              output,
            ].flatten.map { |line| "#{headline}#{line}" },
          ].flatten.join("\n")
        end
      end
    end
  end
end
