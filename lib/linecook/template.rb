require 'linecook/context'
require 'erb'
autoload(:YAML, "yaml")

module Linecook
  class Template
    LC_EXTNAME = '.lc'

    attr_reader :template_file
    attr_reader :template_root

    def initialize(template_file, attributes = {}, template_root = Dir.pwd)
      @template_file = template_file
      @template_root = template_root
      @attributes = attributes
    end

    def properties
      @properties ||= YAML.load(sections.first)
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

    def name
      template_file[(template_root.length + 1)..-1].chomp(LC_EXTNAME)
    end

    def type
      case
      when File.directory?(template_file) then :dir
      when File.extname(template_file) == LC_EXTNAME then :template
      else :file
      end
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
      context_class.new(attrs, fields, default_fields.values, template_file, template_root)
    end

    def erb
      @erb ||= begin
        erb = ERB.new(sections.last, nil, trim_mode)
        erb.filename = template_file
        erb
      end
    end

    def result(fields)
      case type
      when :template then context(fields).__render__(erb)
      when :file then text
      else
        template_dir = self.template_file
        template_files = Dir.glob(File.expand_path("**/*", template_dir))
        template_files.select! {|template_file| File.file?(template_file) }
        template_files.map do |template_file|
          template = self.class.new(template_file, @attributes, template_dir)
          result = template.result(fields)
          "[#{template.filename}] #{template.mode ? template.mode.to_s(8) : '-'} #{result.length}\n#{result}"
        end.join("")
      end
    end

    private

    def text
      type == :dir ? "" : File.read(template_file)
    end

    def sections
      @sections ||= begin
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
