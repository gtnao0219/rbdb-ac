# frozen_string_literal: true

module Rbdb
  module Query
    class Token
      attr_reader :kind, :value
      def initialize(kind, value = nil)
        @kind = kind
        @value = value
      end
    end
  end
end
