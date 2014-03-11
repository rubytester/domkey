module Domkey

  module Page

    class PageObjectCollection < PageObject
      include Enumerable

      # each PageObject from a collection defined by watirproc
      def each
        instantiator.each do |e|
          yield PageObject.new(lambda { e }, @container)
        end
      end

      def [] idx
        to_a[idx]
      end

      alias_method :size, :count

      # ---------------- this is only for pageobject

      def set
        fail
      end

      def value
        fail
      end

      def element
        fail
      end

    end
  end
end
