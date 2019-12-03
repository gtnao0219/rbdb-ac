# frozen_string_literal: true

module Rbdb
  module Query
    module Ast
      class SelectStatement
        def initialize(table_name:, select_list:, search_condition: nil)
          @table_name = table_name
          @select_list = select_list
          @search_condition = search_condition
        end

        def to_str
          res = "--SELECT STATEMENT--\n"
          res += "table: #{@table_name}\n"
          res += "columns: "
          res += "*" if @select_list == :asterisk
          @select_list.each do |select_column|
            res += "#{select_column}, "
          end unless @select_list == :asterisk
          res += "\n"
          res += "condition: " + @search_condition if @search_condition
          res
        end
      end
    end
  end
end
