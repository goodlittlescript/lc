require 'linecook/template'
require 'linecook/parser'
require 'tempfile'

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
          template_root = File.expand_path('recipes', dir)
          Dir.glob(File.join(template_root, "**/*")).each do |template_file|
            template = Template.new(template_file, attributes, template_root)
            templates[template.name] ||= template
          end
        end
        templates
      end
    end

    def output(template, &block)
      case
      when output_dir && template.type == :dir
        if File.exists?(output_dir) && ! force
          raise "already exists: #{output_dir.inspect}"
        end

        file = Tempfile.new('linecook')
        yield file
        file.close

        File.open(file.path) do |input|
          while line = input.gets
            if line =~ /^\[(.*)\] (\d+|-) (\d+)/
              target_file = File.join(output_dir, $1)
              target_mode = $2
              target_length = $3.to_i

              target_dir = File.dirname(target_file)
              unless File.exists?(target_dir)
                FileUtils.mkdir_p(target_dir)
              end

              File.open(target_file, 'w') do |output|
                output << input.read(target_length)
              end

              unless target_mode == '-'
                FileUtils.chmod(target_mode.to_i(8), target_file)
              end
            else
              raise "invalid format: #{line.inspect}"
            end
          end
        end

      when output_dir
        output_file = output_dir
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
