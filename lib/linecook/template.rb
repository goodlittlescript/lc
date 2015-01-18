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
      @attributes_file ||= begin
        extname = File.extname(template_file)
        if extname == ".lc"
          template_file
        else
          template_file.chomp(extname) + ".yml"
        end
      end
    end

    def attrs
      @attrs ||= begin
        if File.exists?(attributes_file)
          YAML.load_file(attributes_file) || {}
        else
          {}
        end
      end
    end

    def arg_names=(arg_names)
      @arg_names = arg_names
    end

    def default_args
      @default_args ||= begin
        args = attrs.fetch("args") { {} }
        case args
        when Array
          args = Hash[args.zip(Array.new(args.length))]
        when Hash
          # do nothing
        else
          raise "invalid args: #{args.inspect} (#{attributes_file})"
        end
        args
      end
    end

    def arg_names
      default_args.keys
    end

    def desc
      attrs.fetch("desc", nil)
    end

    def context_class
      @context_class ||= Context.subclass(arg_names)
    end

    def context(args)
      context_class.new(args, default_args.values)
    end

    def text
      @text ||= begin
        text = File.read(template_file)
        extname = File.extname(template_file)
        if extname == ".lc"
          text = text.split("---\n", 2).last
        end
        text
      end
    end

    def erb
      @erb ||= begin
        erb = ERB.new(text)
        erb.filename = template_file
        erb
      end
    end

    def result(args)
      context(args).__render__(erb)
    end
  end
end
