module Domkey
  module Exception
    class Error < StandardError
    end
    class NotImplementedError < Error
    end
    class NotFoundError < Error
    end
  end
end