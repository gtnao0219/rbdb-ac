# frozen_string_literal: true

require 'rbdb/query/ast/select_statement'
require 'rbdb/query/ast/insert_statement'
require 'rbdb/query/ast/create_statement'
require 'rbdb/query/ast/search_condition'
require 'rbdb/query/ast/table_element'

module Rbdb
  module Query
    class Parser
      def initialize(tokens)
        @tokens = tokens
        @cur = 0
      end

      def parse
        case @tokens[0].kind
        when :select_keyword
          select_statement
        when :create_keyword
          create_statement
        when :insert_keyword
          insert_statement
        else
          raise @tokens[0].kind.to_s
        end
      end

      private

      def peek(n = 1)
        @cur += n
      end

      def expect(kind)
        current_token = @tokens[@cur]
        return nil unless current_token.kind == kind
        peek
        current_token
      end

      def expect!(kind)
        current_token = expect(kind)
        raise 'parse error' unless current_token
        current_token
      end

      def select_statement
        expect!(:select_keyword)
        sl = select_list
        expect!(:from_keyword)
        table_name = expect!(:string_literal).value
        sc = search_condition if expect(:where_keyword)
        Rbdb::Query::Ast::SelectStatement.new(
          table_name: table_name,
          select_list: sl,
          search_condition: sc,
        )
      end

      def create_statement
        expect!(:create_keyword)
        expect!(:table_keyword)
        table_name = expect!(:string_literal).value
        tel = table_element_list
        Rbdb::Query::Ast::CreateStatement.new(
          table_name: table_name,
          table_element_list: tel,
        )
      end

      def insert_statement
        expect!(:insert_keyword)
        expect!(:into_keyword)
        table_name = expect!(:string_literal).value
        expect!(:values_keyword)
        expect!(:left_paren)
        rvl = []
        rvl << row_value
        while expect(:comma) do
          rvl << row_value
        end
        expect!(:right_paren)
        Rbdb::Query::Ast::InsertStatement.new(
          table_name: table_name,
          row_value_list: rvl,
        )
      end

      def select_list
        return :asterisk if expect(:asterisk)
        columns = []
        columns << expect!(:string_literal).value
        while expect(:comma) do
          columns << expect!(:string_literal).value
        end
        columns
      end

      def search_condition
        lo = expect!(:string_literal).value
        co = comp_operator
        ro = row_value
        Rbdb::Query::Ast::SearchCondition.new(
          left_operand: lo,
          comp_operator: co,
          right_operand: ro,
        )
      end

      def comp_operator
        if expect(:equal) then
          :equal
        elsif expect(:not_equal) then
          :not_equal
        elsif expect(:greater_than) then
          :greater_than
        elsif expect(:greater_than_equal) then
          :greater_than_equal
        elsif expect(:less_than) then
          :less_than
        elsif expect(:less_than_equal) then
          :less_than_equal
        else
          raise 'parse error'
        end
      end

      def row_value
        nl = expect(:numeric_literal)
        return nl.value if nl
        expect!(:quote)
        sl = expect!(:string_literal)
        expect!(:quote)
        sl.value
      end

      def table_element_list
        expect!(:left_paren)
        tel = []
        tel << table_element
        while expect(:comma) do
          tel << table_element
        end
        expect!(:right_paren)
        tel
      end

      def table_element
        column_name = expect!(:string_literal).value
        dt = data_type
        Rbdb::Query::Ast::TableElement.new(
          column_name: column_name,
          data_type: dt,
        )
      end

      def data_type
        if expect(:int_keyword) then
          :int
        elsif expect(:varchar_keyword) then
          :varchar
        else
          raise 'parse error'
        end
      end
    end
  end
end