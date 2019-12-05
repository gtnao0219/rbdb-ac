# frozen_string_literal: true

module Rbdb
  module Storage
    class Manager
      def initialize
        @pages = {}
      end

      def read(page_id)
        @pages[page_id]
      end

      def write(page_id, tuple)
        @pages[page_id] ||= []
        @pages[page_id] << tuple
      end
    end
  end
end
