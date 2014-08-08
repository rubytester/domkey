module Domkey
  module View
    module OptionSelectable

      # clears all options and sets only the desired value(s)
      # @param [String, Regexp] sets default designated option by String or Regexp
      # @param [Array<String, Regexp>] set more than one option by default strategy
      # @param [False] unselects all options
      # @param [Hash{how => value}] selects by how strategy where how is a symbol :label, :index, :text, :value
      # Clients need to implement individual strategy for each 'how' => 'value' pair based on what it means to be selected by what
      def set value
        before_set
        set_strategy value
      end

      # @param opts [Symbol, Array<Symbol>] defaults to empty []. Represents a qualifier how to present selected options.
      # @return [Array<String>] When opts param empty? array of default strings implemented by client as a presentation of options selected
      # @param opts [Symbol,Array<Symbol>] ask for representation of options by 'what'
      # @return [Array<Hash{what => value}] Whe opts is a list of symbols :index, :value, :text, :label corresponding to 'what' key
      def value *opts
        opts = opts.flatten
        return value_by_default if non_qualfiers?(opts)
        value_by_options opts
      end

      # @see +value+ returns all options and not only selected ones
      def options *opts
        opts = opts.flatten
        return options_by_default if non_qualfiers?(opts)
        options_by opts
      end

      private

      # qualifier requires symbols else it's default
      def non_qualfiers?(opts)
        opts.empty? || opts.include?(nil) || opts.find { |e| e.kind_of?(String) }
      end

      def options_by_default
        fail Exception::NotImplementedError, "Subclass responsible for implementing"
      end

      def options_by opts
        fail Exception::NotImplementedError, "Subclass responsible for implementing"
      end

      def value_by_default
        fail Exception::NotImplementedError, "Subclass responsible for implementing"
      end

      def value_by_options options
        fail Exception::NotImplementedError, "Subclass responsible for implementing"
      end

      def before_set
        # hook. client can provide actions to be taken before setting this PageObject
      end

      # strategy for selecting OptionSelectable object
      def set_strategy value
        case value
        when TrueClass, FalseClass, Symbol
          set_by_symbol(value)
        when String, Regexp
          set_by_value(value)
        when Array
          value.each { |v| set_strategy(v) }
        when Hash
          value.each_pair do |how, value|
            case how
            when :label, :text
              set_by_label(value)
            when :index
              set_by_index(value)
            when :value
              set_by_value(value)
            end
          end
        else
          fail(Exception::NotImplementedError, "Unable to be set by this value: #{value.inspect}")
        end
      end

      # true, false, or some symbol identifier
      def set_by_symbol value
        fail Exception::NotImplementedError, "Subclass responsible for implementing"
      end

      # default strategy. set by value attribute
      def set_by_value value
        fail Exception::NotImplementedError, "Subclass responsible for implementing"
      end

      # by visible text, label of the control
      def set_by_label value
        fail Exception::NotImplementedError, "Subclass responsible for implementing"
      end

      # set by position in an index of options
      def set_by_index value
        fail Exception::NotImplementedError, "Subclass responsible for implementing"
      end

    end
  end
end
