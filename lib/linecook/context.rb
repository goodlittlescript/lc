module Linecook
  class Context < BasicObject
    class << self
      attr_accessor :defaults

      def subclass(attr_names, field_names)
        method_defs = []
        attr_names.each do |name|
          method_defs << "def #{name}; @attrs['#{name}']; end;"
        end
        field_names.each_with_index do |name, i|
          method_defs << "def #{name}; @fields[#{i}] || @defaults[#{i}]; end;"
        end

        subclass = Class.new(self)  
        subclass.class_eval method_defs.join("\n")
        subclass
      end
    end

    attr_reader :attrs
    attr_reader :fields

    def initialize(attrs, fields, defaults, template_file, template_root)
      @attrs  = attrs
      @fields = fields
      @defaults = defaults
      @template_file = template_file
      @template_root = template_root
    end

    def __template_file__
      @template_file
    end

    def __template_root__
      @template_root
    end

    def __template_name__
      __template_file__[(__template_root__.length + 1)..-1].chomp('.lc')
    end

    def __render__(erb)
      erb.result(::Kernel.binding)
    end
  end
end
