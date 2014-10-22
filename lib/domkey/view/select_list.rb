require 'domkey/view/option_selectable'

module Domkey
  module View

    class SelectList < PageObject

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
          [qualifier, so.map { |o| o.send(qualifier) }]
        end
        Hash[qs_and_vs]
      end

      def value_by_default
        element.selected_options.map { |e| e.value }
      end

      def options_by_default
        element.options.map { |e| e.value }
      end

      def options_by opts
        element.options.map do |o|
          Hash[opts.map { |opt| [opt, o.send(opt)] }]
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
  end
end