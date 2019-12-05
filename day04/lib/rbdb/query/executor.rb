# frozen_string_literal: true

require 'rbdb/catalog/table'
require 'rbdb/query/formatter'

module Rbdb
  module Query
    class Executor
      def initialize(ast, catalog_manager, storage_manager)
        @ast = ast
        @catalog_manager = catalog_manager
        @storage_manager = storage_manager
      end

      def run
        case @ast.statement_type
        when :create
          run_create
        when :insert
          run_insert
        when :select
          run_select
        end
      end

      private

      def run_create
        raise "Table #{@ast.table_name} already exists." if @catalog_manager.find_table(@ast.table_name)
        @catalog_manager.add_table(Rbdb::Catalog::Table.new(
          name: @ast.table_name,
          element_list: @ast.table_element_list,
        ))
        "Table #{@ast.table_name} created."
      end

      def run_insert
        table = @catalog_manager.find_table(@ast.table_name)
        raise "Table #{@ast.table_name} does not exist." unless table
        raise "Column num does not match." if table.column_length != @ast.row_value_list.length
        tuple = []
        @ast.row_value_list.each_with_index do |value, i|
          column = table.find_column_by_order(i)
          data_type = column.data_type
          case data_type
          when :int
            raise "Column #{column.name} type is int." unless value.is_a?(Integer)
          when :varchar
            raise "Column #{column.name} type is varchar." unless value.is_a?(String)
          end
          tuple << value
        end
        @storage_manager.write(@ast.table_name, tuple)
        "1 record inserted."
      end

      def run_select
        table = @catalog_manager.find_table(@ast.table_name)
        raise "Table #{@ast.table_name} does not exist." unless table
        records = @storage_manager.read(@ast.table_name)
        if @ast.search_condition then
          left_column = table.find_column_by_name(@ast.search_condition.left_operand)
          raise "Column #{left_column} does not exist." unless left_column
          records = records.select do |record|
            case @ast.search_condition.comp_operator
            when :equal
              record[left_column.order] == @ast.search_condition.right_operand
            when :not_equal
              record[left_column.order] != @ast.search_condition.right_operand
            when :greater_than
              record[left_column.order] > @ast.search_condition.right_operand
            when :greater_than_equal
              record[left_column.order] >= @ast.search_condition.right_operand
            when :less_than
              record[left_column.order] < @ast.search_condition.right_operand
            when :less_than_equal
              record[left_column.order] <= @ast.search_condition.right_operand
            end
          end
        end
        unless @ast.select_list == :asterisk then
          records = records.map do |record|
            orders = @ast.select_list.map do |name|
              column = table.find_column_by_name(name)
              raise "Column #{name} does not exist." unless column
              column.order
            end
            orders.map { |order| record[order] }
          end
        end

        Rbdb::Query::Formatter.select_result(
          @ast.select_list == :asterisk ? table.order : @ast.select_list,
          records,
        )
      end
    end
  end
end
