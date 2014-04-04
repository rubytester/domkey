module Domkey
  module View
    module OptionSelectable

      # clears all options and sets only the desired value(s)
      # @param [String, Regexp] sets default designated option by String or Regexp
      # @param [Array<String, Regexp>] sets each String, Regexp
      # @param [False] unselects all options
      # @param [Hash{how => value}] selects by how strategy where how is a symbol :label, :index, :text, :value
      # Clients need to implement individual strategy for each 'how' => 'value' pair based on what it means to be selected by what
      def set value
        before_set
        set_strategy value
      end

      private

      def before_set
        # hook. client can provide actions to be taken before setting this PageObject
      end

      # strategy for selecting OptionSelectable object
      def set_strategy value
        case value
        when String
          set_by_string(value)
        when Regexp
          set_by_regexp(value)
        when Array
          value.each { |v| set_strategy(v) }
        when Hash
          value.each_pair do |how, value|
            case how
            when :label
              set_by_label(value)
            when :text
              set_strategy(value)
            when :index
              set_by_index(value)
            when :value
              set_by_value(value)
            end
          end
        end
      end

      def set_by_string value
        fail Exception::NotImplementedError, "Subclass responsible for implementing"
      end

      def set_by_regexp value
        fail Exception::NotImplementedError, "Subclass responsible for implementing"
      end

      def set_by_label value
        fail Exception::NotImplementedError, "Subclass responsible for implementing"
      end

      def set_by_index value
        fail Exception::NotImplementedError, "Subclass responsible for implementing"
      end

      def set_by_value value
        fail Exception::NotImplementedError, "Subclass responsible for implementing"
      end

    end
  end
end
