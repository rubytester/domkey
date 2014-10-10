require 'domkey/view/option_selectable_group'

module Domkey

  module View

    # CheckboxGroup allows you to interact with PageObjectCollection of checkboxes as a single PageObject.
    # Acts like OptionSelectable
    # Checkboxes collection is constrained by the same name attribute
    # Behaves like a multi Select list.
    # It can have none, one or more options selected
    class CheckboxGroup < OptionSelectableGroup

      private

      def set_by_symbol value
        case value
        when FalseClass, TrueClass
          each { |o| o.set value }
        else
          fail(Exception::NotImplementedError, "Unknown way of setting by value: #{value.inspect}")
        end
      end
    end
  end
end
