require 'yaml'

module Choria
  class Colt
    class Cache
      def initialize(path:, force_refresh: false)
        @path = path
        @data = YAML.safe_load File.read(@path)
        @clean = true unless force_refresh
      rescue Errno::ENOENT
        @clean = false
      end

      def dirty?
        !clean?
      end

      def clean?
        @clean
      end

      def load
        @data
      end

      def save(data)
        @data = data
        File.write @path, data.to_yaml
        @clean = true
      end
    end
  end
end
