# frozen_string_literal: true

module Rbdb
  module Catalog
    class Column
      attr_reader :name, :data_type, :order
      def initialize(name:, data_type:, order:)
        @name = name
        @data_type = data_type
        @order = order
      end
    end
  end
end