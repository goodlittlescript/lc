module Linecook
  class Context < BasicObject
    class << self
      attr_accessor :defaults

      def subclass(arg_names)
        method_defs = []
        arg_names.each_with_index do |arg, i|
          method_defs << "def #{arg}; @args[#{i}] || @defaults[#{i}]; end;"
        end

        subclass = Class.new(self)  
        subclass.class_eval method_defs.join("\n")
        subclass
      end
    end

    attr_reader :args

    def initialize(args, defaults)
      @args = args
      @defaults = defaults
    end

    def __render__(erb)
      erb.result(::Kernel.binding)
    end
  end
end
