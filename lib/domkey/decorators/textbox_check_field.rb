module DomKey
  module Decorators
    class TextboxCheckField

      def initialize(page_object)
        @po = page_object
      end

      def set value
        return @po.set switch: false unless value
        if value.kind_of? String
          @po.set switch: true, blurb: value
        else
          @po.set switch: true
        end
      end

    end
  end
end