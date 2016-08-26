require 'webrick'
require 'data'
require 'json'
require 'erb'

module Rubrowser
  class Server < WEBrick::HTTPServer
    include ERB::Util

    def self.start(paths)
      new(paths).start
    end

    def initialize(paths)
      super Port: 9000

      @data = Rubrowser::Data.new(paths)
      @data.parse

      mount_proc '/' do |req, res|
        res.body = root(req.path)
      end

      trap('INT') { shutdown }
    end

    private

    attr_reader :data

    def root(path)
      return file(path) if file?(path)
      erb :index
    end

    def file?(path)
      path = resolve_file_path("/public#{path}")
      File.file?(path)
    end

    def file(path)
      File.read(resolve_file_path("/public#{path}"))
    end

    def erb(template)
      path = resolve_file_path("/views/#{template}.erb")
      file = File.open(path).read
      ERB.new(file).result binding
    end

    def resolve_file_path(path)
      File.expand_path("../..#{path}", __FILE__)
    end
  end
end