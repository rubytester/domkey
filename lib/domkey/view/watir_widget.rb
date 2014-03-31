module Domkey

  module View

    # @api private
    class WatirWidget

      def initialize(object)
        @object           = object
        object_class_name = @object.class.name.split('::').last
        @set_method       = "set_%s" % object_class_name
        @value_method     = "value_%s" % object_class_name
      end

      def set value
        return __send__(@set_method, value) if respond_to?(@set_method, true)
        @object.set value
      end

      def value
        return __send__(@value_method) if respond_to?(@value_method, true)
        @object.value
      end

      private

      # for Watir::Select
      # @param [String] text or label to be selected. Text visible to the user on the page
      # @param [Array<String>] collection for multiselect to select
      def set_Select value
        @object.clear if @object.multiple?
        set_Select_strategy value
      end

      def set_Select_strategy value
        case value
        when String
          @object.select value
        when Array
          value.each { |v| set_Select_strategy v }
        when Hash
          value.each_pair do |how, what|

            #-- select by option position: can be one or many index: 0, index: [0,1,2,3]
            if how == :index
              case what
              when Fixnum
                @object.options[what].select
              when Array
                what.each do |i|
                  @object.options[i].select
                end
              end
            end

            #-- select by option value: attribute (invisible to the user)
            if how == :value
              case what
              when String
                @object.select_value what
              when Array
                what.each { |v| @object.select_value v }
              end
            end

            #-- select by text visible to the user. This is the same as default set 'Text' behavior
            if how == :text
              case what
              when String
                set_Select_strategy what
              when Array
                what.each { |v| set_Select_strategy v }
              end
            end

          end

        end

      end

      # @return [String] text or label from Select, not actual 'value' attribute?
      # @return [Array<String>] collection for multiselect list
      # @return [False] when nothing selected in multiselect list
      def value_Select
        texts = @object.selected_options.map { |o| o.text }
        return texts.first if texts.count == 1 # only one selected
        return texts #multiselect list more than one selected
      end


    end
  end
end