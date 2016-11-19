require 'linecook/template'
require 'linecook/parser'
require 'fileutils'

module Linecook
  class Config
    class << self
      def options(overrides = {})
        {
          :path => ENV["LINECOOK_PATH"] || default_template_dirs.join(":"),
          :field_sep => ',',
          :attributes => {},
          :output_dir => nil,
          :force => false,
        }.merge(overrides)
      end

      def setup(options = {})
        options = self.options(options)
        config  = {}

        path = options[:path]
        config[:template_dirs] = path.split(":")
        config[:field_sep] = options[:field_sep]
        config[:headers] = options[:headers]
        config[:attributes] = options[:attributes]
        config[:output_dir] = options[:output_dir]
        config[:force] = options[:force]

        new(config)
      end

      def default_template_dirs
        ["~/.linecook", "/etc/linecook"]
      end
    end

    attr_reader :template_dirs
    attr_reader :field_sep
    attr_reader :headers
    attr_reader :attributes
    attr_reader :output_dir
    attr_reader :force

    def initialize(config = {})
      @template_dirs  = config.fetch(:template_dirs) { [] }
      @field_sep      = config.fetch(:field_sep, ',')
      @headers        = config.fetch(:headers, nil)
      @attributes     = config.fetch(:attributes) { {} }
      @output_dir     = config.fetch(:output_dir, nil)
      @force          = config.fetch(:force, false)
    end

    def parser(source, field_names = nil)
      Parser.new(source,
        :field_sep => field_sep,
        :headers   => headers,
        :field_names => field_names,
      )
    end

    def template_files
      templates_files = {}
      templates.each_pair do |name, template|
        templates_files[name] = template.template_file
      end
      templates_files
    end

    def templates
      @templates ||= begin
        templates = {}
        template_dirs.each do |dir|
          dir = File.expand_path(dir)
          Dir.glob(File.join(dir, "recipes/**/*.lc")).each do |file|
            name = file[(dir.length + 9)...-3]
            template = Template.new(file, attributes)
            templates[name] ||= template
          end
        end
        templates
      end
    end

    def output(template, &block)
      if output_dir
        output_file = File.expand_path(template.filename, output_dir)
        parent_dir  = File.dirname(output_file)

        unless File.exists?(parent_dir)
          FileUtils.mkdir_p(parent_dir)
        end

        if File.exists?(output_file) && ! force
          raise "already exists: #{output_file.inspect}"
        end

        File.open(output_file, "w", &block)

        if mode = template.mode
          FileUtils.chmod(mode, output_file)
        end
      else
        yield $stdout
      end
    end
  end
end
