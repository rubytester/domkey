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
        case value
        when String
          @object.select value
        when Hash
          value.each_pair { |k, v| set_Select_by(k, v) }
        when Array
          value.each { |v| set_Select v }
        end
      end

      def set_Select_by how, what
        @object.options[what].select if how == :index
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