require 'domkey/view/option_selectable'

module Domkey
  module View

    class SelectList < PageObject

      include OptionSelectable

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
        element.selected_options.map do |o|
          Hash[opts.map { |opt| [opt, o.send(opt)] }]
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
          Hash[opts.map { |opt| [opt, o.send(opt)] }]
        end
      end


      def before_set
        element.clear if element.multiple?
      end


    end
  end
end