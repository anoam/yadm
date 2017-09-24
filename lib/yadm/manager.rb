module Yadm

  AlreadyRegistered = Class.new(StandardError)
  UnknownEntity = Class.new(StandardError)

  # Provides registering and resolving objects
  class Manager

    # Registers new object. In future object could be resolved with given key.
    # @param key [Symbol] identifier for further resolving object
    # @param object [Object] any object to store in container
    # @raise [AlreadyRegistered] if given key already was used for other object
    def register_object(key, object)
      container = build_simple_container(object)

      add_container(key, container)
    end

    # Resolve object using given key
    # @param [Symbol] key identifier fo resolving object
    # @return [Object]
    def resolve(key)
      find_container(key).object
    end

    # Register block for future resolving
    # @param key [Symbol] identifier fo resolving object
    # @yieldparam manager [#resolve]
    # @yieldreturn [Object] object to be resolved with given key
    def register(key, &block)
      container = build_lambda_container(block)

      add_container(key, container)
    end

    private

    def add_container(key, container)
      storage.add(key, container)
    end

    def find_container(key)
      storage.find(key)
    end

    def build_simple_container(object)
      SimpleContainer.new(object)
    end

    def build_lambda_container(lambda)
      LambdaContainer.new(self, lambda)
    end

    def storage
      @storage ||= Storage.new
    end

  end
end
