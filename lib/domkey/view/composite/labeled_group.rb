module Domkey
  module View
    module Composite
      class LabeledGroup

        attr_accessor :group

        def initialize group
          @group = group
        end

        # @param value [String] a label text to set
        # @param value [Array<String>] label texts to set
        def set value
          @group.set false
          labels  = build_labels.map { |e| e.element.text }
          indices = [*value].map { |text| labels.index(text) }
          indices.each do |i|
            @group[i].element.set
          end
        end

        # @return Array of selected texts
        def value
          selected_ones = @group.find_all { |e| e.element.set? }
          Labels.for(selected_ones).map { |e| e.element.text }
        end

        def build_labels
          Labels.for @group
        end
      end

      class Labels
        def self.for collection
          collection.map do |e|
            Domkey::View::PageObject.new -> { label(for: e.element.id) }, e.container
          end
        end
      end

    end
  end
end