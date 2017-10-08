module Yadm
  # @private
  # Container for simple resolving
  class SimpleContainer

    attr_reader :object

    # @param object [Object]
    def initialize(object)
      @object = object
    end

    # Won't do anything. Need only for compatibility
    def prepare!; end
  end

  private_constant :SimpleContainer
end
