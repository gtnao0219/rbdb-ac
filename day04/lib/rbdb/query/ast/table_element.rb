# frozen_string_literal: true

module Rbdb
  module Query
    module Ast
      class TableElement
        attr_reader :column_name, :data_type
        def initialize(column_name:, data_type:)
          @column_name = column_name
          @data_type = data_type
        end

        def to_str
          "name: #{@column_name}, data_type: #{@data_type}\n"
        end
      end
    end
  end
end
