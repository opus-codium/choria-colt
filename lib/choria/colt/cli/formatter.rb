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
          [
            pastel.host(result[:sender]).to_s,
            result.dig(:result, '_output').map { |line| "  #{line}" },
          ].join("\n")
        end

        def process_error(result)
          JSON.pretty_generate(result)
        end
      end
    end
  end
end
