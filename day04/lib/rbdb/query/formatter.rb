# frozen_string_literal: true

module Rbdb
  module Query
    class Formatter
      class << self
        def select_result(column_names, records)
          res = '|'
          column_row_lenght = 1
          column_names.each do |name|
            res += " #{name} |"
            column_row_lenght += name.length + 3
          end
          res += "\n"
          res += "-" * column_row_lenght
          res += "\n"
          records.each do |record|
            res += '|'
            record.each do |val|
              res += " #{val} |"
            end
            res += "\n"
          end
          res
        end
      end
    end
  end
end
