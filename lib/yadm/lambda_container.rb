module Yadm
  class LambdaContainer

    def initialize(manager, lambda)
      @lambda = lambda
      @manager = manager
    end

    def object
      lambda.call(manager)
    end

    private

    attr_reader :lambda, :manager
  end
end
