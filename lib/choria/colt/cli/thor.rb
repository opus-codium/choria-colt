require 'thor'
require 'choria/colt/cli'

module Choria
  class Colt
    # Workaround some, still unfixed, Thor behaviors
    #
    # This class extends ::Thor class to
    # - exit with status code sets to `1` on Thor failure (e.g. missing required option)
    # - exit with status code sets to `1` when user calls `msync` (or a subcommand) without required arguments
    # - show subcommands help using `msync subcommand --help`
    class Thor < ::Thor
      def self.start(*args)
        if (Thor::HELP_MAPPINGS & ARGV).any? && subcommands.none? { |command| command.start_with?(ARGV[0]) }
          Thor::HELP_MAPPINGS.each do |cmd|
            if (match = ARGV.delete(cmd))
              ARGV.unshift match
            end
          end
        end
        super
      end

      desc '_invalid_command_call', 'Invalid command', hide: true
      def _invalid_command_call
        self.class.new.help
        exit 1
      end
      default_task :_invalid_command_call

      def self.exit_on_failure?
        true
      end

      def self.is_thor_reserved_word?(word, type) # rubocop:disable Naming/PredicateName
        return false if word == 'run'

        super
      end
    end
  end
end
