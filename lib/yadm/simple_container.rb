module Yadm
  # @private
  # Container for simple resolving
  class SimpleContainer

    attr_reader :object

    # @param object [Object]
    def initialize(object)
      @object = object
    end
  end
end
