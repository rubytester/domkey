module Domkey
  module View
    module Widgetry

      # Dispatcher for Watir::Select object
      class Select < Dispatcher

        # @return [Array<String>] text visible to the user, not actual 'value' attribute which is invisible to the user.
        def value
          original.selected_options.map { |o| o.text }
        end

        # @return [Array<Hash{Symbol => String}>] text: and value: attribute values for the Select
        def options
          original.options.map do |o|
            {text:  o.text,
             value: o.value}
          end
        end

        # @param [String] text or label to be selected. Text visible to the user on the page
        # @param [Array<String>] collection for multiselect to select
        # @param [Hash{Symbol => String, Array<String>}>] index:, value: , text: option values
        def set value
          original.clear if original.multiple?
          set_strategy value
        end

        private

        def set_strategy value
          case value
          when String
            original.select value
          when Array
            value.each { |v| set_strategy v }
          when Hash
            value.each_pair do |how, what|

              #-- select by option position: can be one or many index: 0, index: [0,1,2,3]
              if how == :index
                case what
                when Fixnum
                  original.options[what].select
                when Array
                  what.each do |i|
                    original.options[i].select
                  end
                end
              end

              #-- select by option value: attribute (invisible to the user)
              if how == :value
                case what
                when String
                  original.select_value what
                when Array
                  what.each { |v| original.select_value v }
                end
              end

              #-- select by text visible to the user. This is the same as default set 'Text' behavior
              if how == :text
                case what
                when String
                  set_strategy what
                when Array
                  what.each { |v| set_strategy v }
                end
              end
            end
          end
        end
      end
    end
  end
end