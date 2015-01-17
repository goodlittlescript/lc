require 'erb'

module Linecook
  class Template
    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end

    def text
      File.read(filename)
    end

    def erb
      @erb ||= begin
        erb = ERB.new(text)
        erb.filename = filename
        erb
      end
    end

    def result(binding)
      erb.result(binding)
    end
  end
end
