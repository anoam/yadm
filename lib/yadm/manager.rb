module Yadm

  AlreadyRegistered = Class.new(StandardError)

  class Manager

    # Registers new object. In future object could be resolved with given key.
    # @param [Symbol] key identifier for further resolving object
    # @params [Object] object any object to store in container
    # @raise [AlreadyRegistered] if given key already was used for other object
    def register_object(key, object)
      raise AlreadyRegistered if key_registered?(key)

      storage[key] = object
    end

    # Resolve object using given key
    def resolve(key)
      storage[key]
    end

    private

    def key_registered?(key)
      storage.key?(key)
    end

    def storage
      @storage ||= {}
    end
  end
end
