require 'domkey/view/option_selectable'

module Domkey
  module View

    class SelectList < PageObject

      include OptionSelectable

      def set_by_string value
        element.select value
      end

      def set_by_regexp value
        element.select value
      end

      def set_by_index value
        case value
        when Fixnum
          element.options[value].select
        when Array
          value.each do |i|
            element.options[i].select
          end
        end
      end

      def set_by_value value
        case value
        when String
          element.select_value value
        when Array
          value.each { |v| element.select_value v }
        end
      end

      # iffy
      def value option=:default
        return value_by_default if option == :default
        element.selected_options.map do |o|
          v = [*option].map do |opt|
            [opt, o.send(opt)]
          end
          Hash[v]
        end
      end

      def value_by_default
        element.selected_options.map { |e| e.text }
      end

      # iffy
      def options
        element.options.map do |o|
          {text:  o.text,
           value: o.value,
           index: o.index}
        end
      end


      private

      def before_set
        element.clear if element.multiple?
      end


    end
  end
end