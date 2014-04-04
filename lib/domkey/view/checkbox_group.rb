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

      # @api private
      # unselects all checkboxes before setting it with desired value
      def before_set
        validate_scope
        each { |o| o.set false }
      end
    end
  end
end
