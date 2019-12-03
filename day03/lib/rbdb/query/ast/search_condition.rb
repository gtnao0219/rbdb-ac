# frozen_string_literal: true

module Rbdb
  module Query
    module Ast
      class SearchCondition
        def initialize(left_operand:, comp_operator:, right_operand:)
          @left_operand = left_operand
          @comp_operator = comp_operator
          @right_operand = right_operand
        end

        def to_str
          "#{@left_operand} #{@comp_operator} #{@right_operand}\n"
        end
      end
    end
  end
end
