# frozen_string_literal: true

require 'rbdb/query/token'

module Rbdb
  module Query
    class Lexer
      def initialize(query)
        @query = query
        @sio = StringIO.new(@query)
        @tokens = []
      end
      
      def scan
        while ch = @sio.read(1) do
          if ch == "'" then
            @tokens << Token.new(:quote)
          elsif ch == '(' then
            @tokens << Token.new(:left_paren)
          elsif ch == ')' then
            @tokens << Token.new(:right_paren)
          elsif ch == '*' then
            @tokens << Token.new(:asterisk)
          elsif ch == ',' then
            @tokens << Token.new(:comma)
          elsif ch == ';' then
            @tokens << Token.new(:semicolon)
          elsif ch == '=' then
            @tokens << Token.new(:equal)
          elsif ch == '<' then
            _next = @sio.read(1)
            if _next == '>' then
              @tokens << Token.new(:not_equal)
            elsif _next == '=' then
              @tokens << Token.new(:less_than_equal)
            else
              back
              @tokens << Token.new(:less_than)
            end
          elsif ch == '>' then
            _next = @sio.read(1)
            if _next == '=' then
              @tokens << Token.new(:greater_than_equal)
            else
              back
              @tokens << Token.new(:greater_than)
            end
          elsif ch =~ /[A-Za-z]/ then
            buf = ch
            while _next = @sio.read(1) do
              if _next =~ /[A-Za-z0-9_]/ then
                buf += _next
              else
                back
                break
              end
            end
            _keyword = keyword(buf)
            if _keyword then
              @tokens << Token.new(_keyword)
            else
              @tokens << Token.new(:string_literal, buf)
            end
          elsif ch =~ /[0-9]/ then
            buf = ch
            has_period = false
            while _next = @sio.read(1) do
              if _next =~ /[0-9\.]/ then
                raise 'tokenize error' if has_period && _next == '.'
                has_period = true if _next == '.'
                buf += _next
              else
                back
                break
              end
            end
            if has_period then
              @tokens << Token.new(:numeric_literal, buf.to_f)
            else
              @tokens << Token.new(:numeric_literal, buf.to_i)
            end
          end
        end
        @tokens
      end

      def back
        @sio.seek(-1, IO::SEEK_CUR)
      end

      def keyword(str)
        case str.upcase
        when "SELECT"
          :select_keyword
        when "FROM"
          :from_keyword
        when "WHERE"
          :where_keyword
        when "INSERT"
          :insert_keyword
        when "INTO"
          :into_keyword
        when "VALUES"
          :values_keyword
        when "CREATE"
          :create_keyword
        when "TABLE"
          :table_keyword
        when "INT"
          :int_keyword
        when "VARCHAR"
          :varchar_keyword
        end
      end
    end
  end
end