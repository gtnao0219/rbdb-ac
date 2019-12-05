# frozen_string_literal: true

require 'rbdb/catalog/column'

module Rbdb
  module Catalog
    class Table
      attr_reader :name, :columns, :order
      def initialize(name:, element_list:)
        @name = name
        @columns = {}
        @order = []
        element_list.each_with_index do |element, i|
          @columns[element.column_name] = Rbdb::Catalog::Column.new(
            name: element.column_name,
            data_type: element.data_type,
            order: i,
          )
          @order << element.column_name
        end
      end

      def find_column_by_name(name)
        @columns[name]
      end

      def find_column_by_order(num)
        @columns[@order[num]]
      end

      def column_length
        @order.length
      end
    end
  end
end
