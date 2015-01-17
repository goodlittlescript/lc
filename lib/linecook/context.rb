module Linecook
  class Context < BasicObject
    class << self
      def subclass(arg_names)
        method_defs = []
        arg_names.each_with_index do |arg, i|
          method_defs << "def #{arg}; @args[#{i}]; end;"
        end

        subclass = Class.new(self)  
        subclass.class_eval method_defs.join("\n")
        subclass
      end
    end

    attr_reader :args

    def initialize(args)
      @args = args
    end

    def __render__(erb)
      erb.result(::Kernel.binding)
    end
  end
end
