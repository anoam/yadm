module Yadm

  AlreadyRegistered = Class.new(StandardError)
  UnknownEntity = Class.new(StandardError)

  class Manager

    # Registers new object. In future object could be resolved with given key.
    # @param key [Symbol] identifier for further resolving object
    # @param object [Object] any object to store in container
    # @raise [AlreadyRegistered] if given key already was used for other object
    def register_object(key, object)
      raise AlreadyRegistered if key_registered?(key)

      storage[key] = object
    end

    # Resolve object using given key
    # @param [Symbol] key identifier fo resolving object
    # @return [Object]
    def resolve(key)
      raise UnknownEntity unless key_registered?(key)

      if lambda?(key)
        storage[key].call(self)
      else
        storage[key]
      end
    end

    # Register block for future resolving
    # @param key [Symbol] identifier fo resolving object
    # @yieldparam manager [Yadm::Manager]
    # @yieldreturn [Object] object to be resolved with given key
    def register(key, &block)
      raise AlreadyRegistered if key_registered?(key)

      storage[key] = block
      lambdas.push(key)
    end

    private

    def key_registered?(key)
      storage.key?(key)
    end

    def storage
      @storage ||= {}
    end

    def lambda?(key)
      lambdas.include?(key)
    end

    def lambdas
      @lambdas ||= []
    end
  end
end
