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
          element = @group.element.find_all { |e| e.set? }
          labels  = element.map { |e| @group.container.call.label(for: e.id) }
          labels.map { |l| l.text }
        end

        def build_labels
          Labels.for @group
        end
      end

      class Labels
        def self.for collection
          ids = collection.map { |e| e.element.id }
          ids.map { |id| Domkey::View::PageObject.new -> { label(for: id) }, collection.container }
        end
      end

    end
  end
end