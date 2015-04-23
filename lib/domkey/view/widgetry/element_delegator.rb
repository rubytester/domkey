module Domkey
  module View
    module Widgetry

      # Component delegate to Watir::Element
      module ElementDelegator

        # warning: ActiveResource provides Object#present?
        def present?
          _element.present?
        end

        def wait_until_present(timeout = nil)
          _element.wait_until_present
        end

        # @api private
        # delegate to watir element if element responds to message
        def method_missing(message, *args, &block)
          if _element.respond_to?(message)
            _element.__send__(message, *args, &block)
          else
            super
          end
        end

        # @api private
        # delegate with confidence
        def respond_to_missing?(message, include_private = false)
          _element.respond_to?(message) || super
        end

        private

        # for Component constructed with hash keys
        # extract first element as representative element.
        # XXX Sloppy strategy. Got better idea?
        def _element
          if element.kind_of?(Hash)
            element.first.last
          else
            element
          end
        end

      end
    end
  end
end