module Yadm
  # @private
  # Container for lambda-based resolving
  class LambdaContainer

    # @param lambda [Proc]
    # @param manager [#resolve]
    def initialize(manager, lambda)
      @lambda = lambda
      @manager = manager
      @prepared_object = nil
    end

    # @return [Object] resolved object
    def object
      resolve_object
    end

    # Prepare and cache object
    def prepare!
      self.prepared_object = resolve_object
    end

    private

    attr_reader :lambda, :manager
    attr_accessor :prepared_object

    def resolve_object
      # NOTICE: it is possible that resolved object would be false
      #   I don't see any reasons for that, but who knows?
      return prepared_object unless prepared_object.nil?
      lambda.call(manager)
    end

  end

  private_constant :LambdaContainer
end
