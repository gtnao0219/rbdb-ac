# frozen_string_literal: true

module Rbdb
  module Query
    module Ast
      class InsertStatement
        def initialize(table_name:, row_value_list:)
          @table_name = table_name
          @row_value_list = row_value_list
        end

        def to_str
          res = "--INSERT STATEMENT--\n"
          res += "table: #{@table_name}\n"
          res += "values: "
          @row_value_list.each do |row_value|
            res += "#{row_value}, "
          end
          res += "\n"
          res
        end
      end
    end
  end
end
