require 'linecook/context'
require 'erb'
autoload(:YAML, "yaml")

module Linecook
  class Template
    attr_reader :template_file

    def initialize(template_file, attributes = {})
      @template_file = template_file
      @attributes = attributes
    end

    def properties_file
      @properties_file ||= begin
        extname = File.extname(template_file)
        if extname == ".lc"
          template_file
        else
          template_file.chomp(extname) + ".yml"
        end
      end
    end

    def properties
      @properties ||= begin
        if File.exists?(properties_file)
          YAML.load_file(properties_file) || {}
        else
          {}
        end
      end
    end

    def attrs
      @attrs ||= properties.fetch("attrs") { {} }.merge(@attributes)
    end

    def filename_erb
      @filename_erb ||= begin
        template = properties.fetch("filename", "<%= __template_name__ %>")
        erb = ERB.new(template)
        erb.filename = template_file + " (filename)"
        erb
      end
    end

    def filename
      context([]).__render__(filename_erb)
    end

    def mode
      properties.fetch("mode", nil)
    end

    def field_names=(field_names)
      @field_names = field_names
    end

    def default_fields
      @default_fields ||= begin
        fields = properties.fetch("fields") { {} }
        case fields
        when Array
          fields = Hash[fields.zip(Array.new(fields.length))]
        when Hash
          # do nothing
        else
          raise "invalid fields: #{fields.inspect} (#{properties_file})"
        end
        fields
      end
    end

    def field_names
      default_fields.keys
    end

    def desc
      properties.fetch("desc", nil)
    end

    def context_class
      @context_class ||= Context.subclass(attrs.keys, field_names)
    end

    def context(fields)
      context_class.new(attrs, fields, default_fields.values, template_file)
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

    def result(fields)
      context(fields).__render__(erb)
    end
  end
end
