module Domkey
  module View
    module Widgetry

      # PageObject delegate to Watir::Element
      module ElementDelegator

        # @api private
        # opinionated strategy
        def wait_until_present(timeout = nil)
          e = element
          # default strategy for pageobject with keys. select first to be waitable.
          # when first element of page object is present we can interact with other elements.
          # chances are the other elements may not be present yet
          e = e.first.last if e.kind_of?(Hash)
          e.wait_until_present
        end

        # @api private
        # delegate to element when element responds to message
        def method_missing(message, *args, &block)
          if element.respond_to?(message)
            element.__send__(message, *args, &block)
          else
            super
          end
        end

        # @api private
        # ruturn true when element.respond_to? message so we can delegate with confidence
        def respond_to_missing?(message, include_private = false)
          element.respond_to?(message) || super
        end

      end
    end
  end
end