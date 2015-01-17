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

    def initialize(config)
      @template_dirs = config.fetch(:template_dirs) { [] }
    end

    def template_files
      @template_files ||= begin
        template_files = {}
        template_dirs.each do |dir|
          Dir.glob("#{dir}/*.erb").each do |file|
            name = File.basename(file).chomp(".erb")
            template_files[name] ||= file
          end
        end
        template_files
      end
    end
  end
end
