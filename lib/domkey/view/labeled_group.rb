require 'delegate'
require 'domkey/view/label_mapper'
module Domkey

  module View

    # Interfact to CheckboxGroup and RadioGroup elements through corresponding label elements;
    # radio and checkbox controls form a group by name attribute
    # however they don't have visible text indicators to the user who is looking at the page.
    # The common strategy is to provide a lable element such that
    # its for: attribute value maps to id: attribute value of an individual control in a group.
    # The labels become visual indicators for the user. Clicking corresponding lable activates the control.
    class LabeledGroup < SimpleDelegator

      def initialize group
        __setobj__(group)
      end

      def before_set
        __getobj__.set false
      end

      # @param value [String] a label text to set a corresponding element referenced
      # @param value [Array<String>] one or more labels
      def set value
        before_set
        set_strategy(value)
      end

      # @return [Array<String>] label texts for selected elements
      def value
        selected_ones = __getobj__.find_all { |e| e.element.set? }
        LabelMapper.for(selected_ones).map { |e| e.element.text }
      end

      # @return [Array<String>] label texts for all elements in a group
      def options
        LabelMapper.for(__getobj__).map { |e| e.element.text }
      end

      private

      def set_strategy value
        labels  = self.options
        indices = [*value].map do |what|
          i = case what
              when String
                labels.index(what)
              when Regexp
                labels.index(labels.find { |e| e.match(what) })
              end
          i ? i : fail(Exception::Error, "Label text to set not found for value: #{what.inspect}")
        end
        indices.each do |i|
          __getobj__[i].element.set
        end
      end

    end
  end
end
