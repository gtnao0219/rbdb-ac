# frozen_string_literal: true

module Rbdb
  module Catalog
    class Manager
      attr_reader :tables
      def initialize
        @tables = {}
      end

      def add_table(table)
        @tables[table.name] = table
      end

      def find_table(name)
        @tables[name]
      end
    end
  end
end
