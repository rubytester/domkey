require 'domkey/view/labeled_group'
module Domkey

  module View

    # RadioGroup allows you to interact with PageObjectCollection of radios as a single PageObject
    # Radios collection is constrained by the same name attribute and behaves like one object.
    # It behaves like a single Select list.
    # When one radio is selected in the collection the others become unselected.
    class RadioGroup < PageObjectCollection

      # @param [String] match text in value attribute and set that radio
      def set value
        validate_scope
        return unless value
        [*value].each do |v|
          o = case v
              when String
                find { |e| e.value == v }
              when Regexp
                find { |e| e.value.match(v) }
              end
          o ? o.element.set : fail(Exception::Error, "RadioGroup value not found: #{v.inspect}")
        end
      end

      # @return [String] text in value attribute of currently set
      def value
        validate_scope
        find_all { |o| o.element.set? }.map { |e| e.value }
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
