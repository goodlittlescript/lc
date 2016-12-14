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

    def properties
      @properties ||= (sections.first == '{}' ? {} : YAML.load(sections.first))
    end

    def attrs
      @attrs ||= properties.fetch("attrs") { {} }.merge(@attributes)
    end

    def filename_erb
      @filename_erb ||= begin
        template = properties.fetch("filename", "<%= __template_name__ %>")
        erb = ERB.new(template, nil, trim_mode)
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

    def trim_mode
      properties.fetch("trim", "<>")
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

    def erb
      @erb ||= begin
        erb = ERB.new(sections.last, nil, trim_mode)
        erb.filename = template_file
        erb
      end
    end

    def result(fields)
      context(fields).__render__(erb)
    end

    private

    def sections
      @sections ||= begin
        text = File.read(template_file)
        yaml, erb = text.split("---\n", 2)
        if erb.nil?
          yaml, erb = '{}', yaml
        end
        if yaml.strip.empty?
          yaml = '{}'
        end
        [yaml, erb]
      end
    end
  end
end
