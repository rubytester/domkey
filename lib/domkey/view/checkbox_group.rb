module Domkey

  module View

    # RadioGroup is a PageObjectCollection or radios that acts like a PageObject.
    # It allows you to interact with the collection of radios as a single PageObject
    # when one radio is selected in the collection the others become unselected.
    class CheckboxGroup < PageObjectCollection

      # @param [String] match String value attribute and set that checkbox
      # @param [Array<String>] match String to value attributes and set checkboxes
      def set value
        validate_scope
        element.each { |e| e.clear }
        [*value].each do |v|
          element.find { |e| e.value.match(v) }.set
        end
      end

      # @return [String] value attribute of radio.set? == true
      def value
        validate_scope
        element.find_all { |e| e.set? }.map { |e| e.value }
      end

      def each(&blk)
        validate_scope
        super(&blk)
      end

      def to_a
        validate_scope
        super
      end

      private

      # precondition on acting on this collection
      # @return [true] when all radios in collection share the same name attribute
      # @raise [Exception::Error] when where is more than one unique name attribute
      # --
      # returns true on subsequent unless magically more radios show up after initial validation
      def validate_scope
        return if @validated
        groups = element.map { |e| e.name }.uniq
        fail(Exception::Error, "RadioGroup definition scope too broad: Found #{groups.count} radio groups with names: #{groups}") unless (groups.size == 1)
        @validated = true
      end
    end
  end
end
