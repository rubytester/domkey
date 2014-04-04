require 'domkey/view/option_selectable'
require 'domkey/view/labeled_group'

module Domkey
  module View

    #OptionsSelectable CheckboxGroup, RadioGroup
    class OptionSelectableGroup < PageObjectCollection

      include OptionSelectable

      def set_by_index value
        [*value].each do |i|
          self[i.to_i].set(true)
        end
      end

      def set_by_label value
        to_labeled.__send__(:set_strategy, value)
      end

      def set_by_regexp value
        o = find { |o| o.value.match(value) }
        o ? o.element.set : fail(Exception::NotFoundError, "Element not found with value: #{v.inspect}")
      end

      def set_by_string value
        o = find { |o| o.value == value }
        o ? o.element.set : fail(Exception::NotFoundError, "Element not found with value: #{v.inspect}")
      end


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