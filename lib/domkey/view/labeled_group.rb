require 'delegate'
require 'domkey/view/label_mapper'
module Domkey

  module View

    # allow CheckboxGroup and RadioGroup to bet set by a corresponding label element referring to an element in a collection
    class LabeledGroup < SimpleDelegator

      def initialize group
        __setobj__(group)
      end

      # @param value [String] a label text to set a corresponding element referenced
      # @param value [Array<String>] one or more labels
      def set value
        __getobj__.set false
        labels  = LabelMapper.for(__getobj__).map { |e| e.element.text }
        indices = [*value].map { |text| labels.index(text) }
        indices.each do |i|
          __getobj__[i].element.set
        end
      end

      # @return [Array<String>] label texts for selected elements
      def value
        selected_ones = __getobj__.find_all { |e| e.element.set? }
        LabelMapper.for(selected_ones).map { |e| e.element.text }
      end
    end
  end
end
