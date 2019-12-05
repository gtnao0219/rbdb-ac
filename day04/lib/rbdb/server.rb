# frozen_string_literal: true

require 'webrick'
require 'rbdb/query/lexer'
require 'rbdb/query/parser'
require 'rbdb/query/executor'
require 'rbdb/catalog/manager'
require 'rbdb/storage/manager'

module Rbdb
  class Server
    def initialize(host: 'localhost', port: 40219)
      @host = host
      @port = port
      @catalog_manager = Rbdb::Catalog::Manager.new
      @storage_manager = Rbdb::Storage::Manager.new
    end

    def start
      server.mount_proc '/exec' do |req, res|
        begin
          query = req.query['query']
          tokens = Rbdb::Query::Lexer.new(query).scan
          ast = Rbdb::Query::Parser.new(tokens).parse
          res.body += Rbdb::Query::Executor.new(ast, @catalog_manager, @storage_manager).run
        rescue => exception
          res.body += exception.message
        end
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
