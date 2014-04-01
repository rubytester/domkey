require 'delegate'

module Domkey
  module View
    module Composite
      class LabeledGroup < SimpleDelegator

        attr_accessor :group

        def initialize group
          __setobj__(group)
        end

        # @param value [String] a label text to set
        # @param value [Array<String>] label texts to set
        def set value
          __getobj__.set false
          labels  = Labels.for(__getobj__).map { |e| e.element.text }
          indices = [*value].map { |text| labels.index(text) }
          indices.each do |i|
            __getobj__[i].element.set
          end
        end

        # @return Array of selected texts
        def value
          selected_ones = __getobj__.find_all { |e| e.element.set? }
          Labels.for(selected_ones).map { |e| e.element.text }
        end
      end

      class Labels
        def self.for collection
          collection.map do |e|
            PageObject.new -> { label(for: e.element.id) }, e.container
          end
        end
      end

    end
  end
end