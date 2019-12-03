# frozen_string_literal: true

require 'webrick'
require 'rbdb/query/lexer'
require 'rbdb/query/parser'

module Rbdb
  class Server
    def initialize(host: 'localhost', port: 40219)
      @host = host
      @port = port
    end

    def start
      server.mount_proc '/exec' do |req, res|
        query = req.query['query']
        tokens = Rbdb::Query::Lexer.new(query).scan
        ast = Rbdb::Query::Parser.new(tokens).parse
        # TODO:
        res.body += ast
      end
      trap('INT') do |_|
        terminate
      end
      server.start
      terminate
    rescue Interrupt
      terminate
    end

    private

    def terminate
      server.shutdown
      puts "\ngood bye!"
    end

    def server
      @server ||= WEBrick::HTTPServer.new({
        DocumentRoot: '/',
        BindAddress: @host,
        Port: @port,
      })
    end
  end
end
