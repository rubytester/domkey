module Domkey
  module View
    module Widgetry

      # PageObject delegate to Watir::Element
      module ElementDelegator

        # warning: ActiveResource provides Object#present?
        def present?
          _element.present?
        end

        def wait_until_present(timeout = nil)
          _element.wait_until_present
        end

        # @api private
        # delegate to element when element responds to message
        def method_missing(message, *args, &block)
          if _element.respond_to?(message)
            _element.__send__(message, *args, &block)
          else
            super
          end
        end

        # @api private
        # ruturn true when element.respond_to? message so we can delegate with confidence
        def respond_to_missing?(message, include_private = false)
          _element.respond_to?(message) || super
        end

        private

        # extract first element strategy for pageobject with keys or just element
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