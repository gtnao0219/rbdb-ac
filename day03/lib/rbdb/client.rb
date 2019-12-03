# frozen_string_literal: true

require 'cgi'
require 'net/http'

module Rbdb
  class Client
    def initialize(host: 'localhost', port: 40219)
      @host = host
      @port = port
    end

    def start
      show_title
      show_prompt
      while query = gets.chomp do
        break if terminate_query?(query)
        res = exec_query(query)
        # TODO:
        puts res
        show_prompt
      end
      terminate
    rescue Interrupt
      terminate
    end

    private

    def show_title
      puts <<~'EOS'
              _         _ _
         _ __| |__   __| | |__
        | '__| '_ \ / _` | '_ \
        | |  | |_) | (_| | |_) |
        |_|  |_.__/ \__,_|_.__/
        
      EOS
    end

    def show_prompt
      print '>> '
    end

    def terminate_query?(query)
      query == 'exit' || query == 'quit'
    end

    def exec_query(query)
      Net::HTTP.get(@host, "/exec?query=#{CGI.escape(query)}", @port)
    end

    def terminate
      puts "\ngood bye!"
    end
  end
end
