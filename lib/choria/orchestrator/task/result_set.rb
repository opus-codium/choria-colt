require 'choria/colt/data_structurer'

module Choria
  class Orchestrator
    class Task
      class ResultSet
        attr_reader :results

        attr_accessor :pending_count

        def initialize(on_result:)
          @results = []
          @on_result = on_result
          @pending_count = 0
        end

        def integrate_rpc_error(rpc_error)
          result = rpc_error[:body]
          result[:sender] = rpc_error[:senderid]
          integrate_result(result)
        end

        def integrate_result(result)
          structured_result = Choria::Colt::DataStructurer.structure(result).with_indifferent_access
          @results << structured_result
          @on_result&.call(structured_result, @results.count, pending_count + @results.count)
        end
      end
    end
  end
end
