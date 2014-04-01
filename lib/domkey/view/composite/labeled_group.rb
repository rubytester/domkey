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
          container = @group.container.call
          labels = @group.map { |e| container.label(for: e.element.id) }
          values_to_set = []
          if value.kind_of? Array
            value.each do |v|
              label = labels.find { |l| l.text == v }
              values_to_set << @group.find { |e| e.element.id == label.for }.value unless label.nil?
            end
            @group.set values_to_set
          else
            label = labels.find { |l| l.text == value }
            @group.set @group.find { |e| e.element.id == label.for }.value
          end
        end

        # @return Array of selected texts
        def value
          element = @group.element.find_all { |e| e.set? }
          labels = element.map { |e| @group.container.call.label(for: e.id) }
          labels.map { |l| l.text }
        end
      end
    end
  end
end