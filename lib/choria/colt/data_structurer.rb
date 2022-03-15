module Choria
  class Colt
    module DataStructurer
      def self.structure(results)
        results.map do |res|
          # data.stdout seems to always be JSON, so parse it once.
          res[:result] = JSON.parse res[:data][:stdout]
          res[:data].delete :stdout

          # On one side, data.stderr is filled by the remote execution stderr.
          # On the other side, error description is in JSON (ie. '_error')
          # So merge data.stderr in '_error'.'details'
          unless res[:data][:stderr].empty?
            raise NotImplementedError, 'What to do when res[:data][:stderr] contains something?' if res[:result]['_error'].empty?

            res[:result]['_error']['details'].merge!({ 'stderr' => res[:data][:stderr].split("\n") })
          end
          res[:data].delete :stderr

          # Convert '_output' (ie. stdout) lines into array
          res[:result]['_output'] = res[:result]['_output'].split("\n")

          res
        end
      end
    end
  end
end
