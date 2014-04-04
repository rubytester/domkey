require 'domkey/view/labeled_group'
module Domkey

  module View

    # Acts like OptionSelectable object
    # CheckboxGroup allows you to interact with PageObjectCollection of checkboxes as a single PageObject.
    # Checkboxes collection is constrained by the same name attribute and acts like on object.
    # It behaves like a Multi Select list.
    # It can none, one or more options selected
    class CheckboxGroup < PageObjectCollection

      # clears all options and sets only the desired value(s)
      # @param [String, Regexp] find value attribute or match value and set that checkbox
      # @param [Array<String, Regexp>] find each value attribute and set each checkbox
      # @param [False] uncheck any checked checkboxes
      def set value
        validate_scope
        each { |o| o.set false }
        return unless value
        [*value].each do |v|
          o = case v
              when String
                find { |o| o.value == v }
              when Regexp
                find { |o| o.value.match(v) }
              end
          o ? o.element.set : fail(Exception::Error, "Checkbox to be set not found by value: #{v.inspect}")
        end
      end

      # @return [Array<String>] value attributes of each checked checkbox
      def value
        validate_scope
        find_all { |e| e.element.set? }.map { |e| e.value }
      end

      def options
        validate_scope
        map { |e| e.value }
      end

      # convert to LabeledGroup settable by corresponding label text
      def to_labeled
        LabeledGroup.new(self)
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
