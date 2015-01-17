require 'linecook/context'
require 'erb'
autoload(:YAML, "yaml")

module Linecook
  class Template
    attr_reader :template_file

    def initialize(template_file)
      @template_file = template_file
    end

    def attributes_file
      @attributes_file ||= template_file.sub(/\.erb$/, ".yml")
    end

    def attrs
      @attrs ||= begin
        if File.exists?(attributes_file)
          YAML.load_file(attributes_file)
        else
          {}
        end
      end
    end

    def arg_names=(arg_names)
      @arg_names = arg_names
    end

    def arg_names
      @arg_names ||= attrs.fetch("args") { [] }.map(&:to_s)
    end

    def context_class
      @context_class ||= Context.subclass(arg_names)
    end

    def context(args)
      context_class.new(args)
    end

    def erb
      @erb ||= begin
        erb = ERB.new(File.read(template_file))
        erb.filename = template_file
        erb
      end
    end

    def result(args)
      context(args).__render__(erb)
    end
  end
end
