module Domkey

  module View

    # CheckboxGroup allows you to interact with PageObjectCollection of checkboxes as a single PageObject.
    # Checkboxes collection is constrained by the same name attribute and acts like on object.
    # It behaves like a Multi Select list.
    # It can none, one or more items selected
    class CheckboxGroup < PageObjectCollection

      # sets by value. unchecks others
      # @param [String] match String value attribute and set that checkbox
      # @param [Array<String>] match String to value attributes and set checkboxes
      # @param [False] uncheck any checked checkboxes
      def set value
        validate_scope
        element.each { |e| e.clear if e.set? }
        return unless value
        [*value].each do |v|
          element.find { |e| e.value.match(v) }.set
        end
      end

      # @return [Array<String>] value attributes of each checked checkbox
      def value
        validate_scope
        element.find_all { |e| e.set? }.map { |e| e.value }
      end

      # @yield [PageObject]
      def each(&blk)
        validate_scope
        super(&blk)
      end

      # @return [Array<PageObject>]
      def to_a
        validate_scope
        super
      end

      private

      # precondition on acting on this collection
      # @return [true] when all checkboxes in collection share the same name attribute
      # @raise [Exception::Error] when where is more than one unique name attribute
      # --
      # returns true on subsequent unless magically more radios show up after initial validation
      def validate_scope
        return if @validated
        groups = element.map { |e| e.name }.uniq
        fail(Exception::Error, "CheckboxGroup definition scope too broad: Found #{groups.count} checkbox groups with names: #{groups}") unless (groups.size == 1)
        @validated = true
      end
    end
  end
end
