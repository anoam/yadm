module Yadm
  # @private
  # Container for lambda-based resolving
  class LambdaContainer

    # @param lambda [Proc]
    # @param manager [#resolve]
    def initialize(manager, lambda)
      @lambda = lambda
      @manager = manager
    end

    # @return [Object] resolved object
    def object
      lambda.call(manager)
    end

    private

    attr_reader :lambda, :manager
  end
end
