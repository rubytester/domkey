require 'domkey/view/option_selectable'

module Domkey
  module View

    class SelectList < Component

      include OptionSelectable

      private

      # by position in options array
      def set_by_index value
        [*value].each { |i| element.options[i].select }
      end

      # by value attribute of the option
      def set_by_value value
        [*value].each { |v| element.select_value(v) }
      end

      # by visible text for the option (visible to the user)
      def set_by_label value
        [*value].each { |v| element.select(v) }
      end

      def value_by_options opts
        so        = element.selected_options
        qs_and_vs = opts.map do |qualifier|
          [qualifier, so.map { |o| option_value_by_qualifier(o, qualifier) }]
        end
        Hash[qs_and_vs]
      end

      def option_value_by_qualifier o, qualifier
        if o.respond_to?(qualifier)
          o.__send__(qualifier)
        else
          fail Exception::NotImplementedError, "Unknown option qualifier: #{qualifier.inspect}"
        end
      end

      def value_by_default
        element.selected_options.map { |e| e.value }
      end

      def options_by_default
        element.options.map { |e| e.value }
      end

      def options_by opts
        element.options.map do |o|
          Hash[opts.map { |opt| [opt, o.__send__(opt)] }]
        end
      end

      def set_by_symbol value
        case value
        when FalseClass
          element.clear if element.multiple?
        when TrueClass
          return #noop
        else
          fail(Exception::NotImplementedError, "Unknown way of setting by value: #{value.inspect}")
        end
      end
    end

    # factory create Component SelectList in your current view respecting current watir container
    # notice we build Domkey::View::SelectList Component that acts as a facade for Watir::SelectList
    # example:
    # select_list(:fruit) { select_list(id: 'fruit') }
    register_dom_factory :select_list, SelectList
  end
end