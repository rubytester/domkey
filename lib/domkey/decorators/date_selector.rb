module Domkey
  module Decorators
    class DateSelector
      def initialize page_object
        @po = page_object
      end

      def set value
        @po.set day: value.day, month: value.month, year: value.year
      end

      def value
        h = @po.value
        Date.parse "%s/%s/%s" % [h[:year], h[:month], h[:day]]
      end
    end
  end
end