require 'linecook/template'
autoload :CSV, 'csv'

module Linecook
  class Config
    class << self
      def options(overrides = {})
        {
          :path => ENV["LC_PATH"] || default_template_dirs.join(":"),
        }.merge(overrides)
      end

      def setup(options = {})
        options = self.options(options)
        config  = {}

        path = options[:path]
        config[:template_dirs] = path.split(":")

        new(config)
      end

      def default_template_dirs
        []
      end
    end

    attr_reader :template_dirs
    attr_reader :csv_options

    def initialize(config)
      @template_dirs = config.fetch(:template_dirs) { [] }
      @csv_options = {}
    end

    def parse_csv(line)
      CSV.parse_line(line, csv_options)
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
          Dir.glob("#{dir}/*.erb").each do |file|
            name = File.basename(file).chomp(".erb")
            template = Template.new(file)
            templates[name] ||= template
          end
        end
        templates
      end
    end
  end
end
