module Linecook
  class Context < BasicObject
    class << self
      attr_accessor :defaults

      def subclass(field_names)
        method_defs = []
        field_names.each_with_index do |field, i|
          method_defs << "def #{field}; @fields[#{i}] || @defaults[#{i}]; end;"
        end

        subclass = Class.new(self)  
        subclass.class_eval method_defs.join("\n")
        subclass
      end
    end

    attr_reader :fields

    def initialize(fields, defaults)
      @fields = fields
      @defaults = defaults
    end

    def __render__(erb)
      erb.result(::Kernel.binding)
    end
  end
end
