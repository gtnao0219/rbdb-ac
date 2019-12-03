# frozen_string_literal: true

module Rbdb
  module Query
    module Ast
      class CreateStatement
        def initialize(table_name:, table_element_list:)
          @table_name = table_name
          @table_element_list = table_element_list
        end

        def to_str
          res = "--CREATE STATEMENT--\n"
          res += "table: #{@table_name}\n"
          res += "columns:\n"
          @table_element_list.each do |table_element|
            res += "  " + table_element
          end
          res
        end
      end
    end
  end
end
