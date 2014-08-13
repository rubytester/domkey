module Domkey
  module View
    module Widgetry

      # page object can be waited for to appear or disapper from view.
      # delegate to Watir::Wait for element
      module Waitable

        def wait_until_present(timeout = nil)
          e = element #extract element widgetry of pageobject
          # default strategy for pageobject with keys. select first to be waitable.
          # when first element of page object is present we can interact with other elements.
          # chances are the other elements may not be present yet
          e = e.first.last if e.kind_of?(Hash)
          e.wait_until_present
        end

      end
    end
  end
end