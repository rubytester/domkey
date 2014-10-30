require 'domkey/view/option_selectable_group'

module Domkey

  module View

    # RadioGroup allows you to interact with PageObjectCollection of radios as a single PageObject
    # Acts like OptionSelectable
    # Radios collection is constrained by the same name attribute
    # Behaves like a single Select list.
    # It has one radio selected at all times
    class RadioGroup < OptionSelectableGroup

      private

      def set_by_symbol value
        case value
        when FalseClass, TrueClass
          return #noop
        else
          fail(Exception::NotImplementedError, "Unknown way of setting by value: #{value.inspect}")
        end
      end

    end

    # factory create PageObject RadioGroup in your current view respecting current container
    # example:
    # radio_group(:tool) { radios(name: 'tool') }
    register_dom_factory :radio_group, RadioGroup
  end
end
