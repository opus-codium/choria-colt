module Choria
  class Colt
    module DataStructurer
      def self.structure(res) # rubocop:disable Metrics/AbcSize
        return res unless [0, 1].include? res[:statuscode]

        # If data is empty, status message is an RPC error
        if res[:data].empty?
          res[:result] = {
            _error: {
              kind: 'choria/rpc',
              msg: res[:statusmsg],
            },
          }
          return res
        end

        # data.stdout seems to always be JSON, so parse it once.
        res[:result] = JSON.parse res[:data][:stdout] unless res.dig(:data, :stdout).nil?
        res[:data].delete :stdout

        # On one side, data.stderr is filled by the remote execution stderr.
        # On the other side, error description is in JSON (ie. '_error')
        # So merge data.stderr in '_error'.'details'
        res[:result]['_stderr'] = res[:data][:stderr].split("\n") unless res.dig(:data, :stderr).nil? || res[:data][:stderr].empty?
        res[:data].delete :stderr

        # Convert '_output' (ie. stdout) lines into array
        res[:result]['_output'] = res[:result]['_output'].split("\n") unless res.dig(:result, '_output').nil?

        res
      end
    end
  end
end
