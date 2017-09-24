module Yadm

  # @private
  # stores and accesses containers
  class Storage

    # Add given container with given key
    # @param key [Symbol] identifier for future finding container
    # @param container [#resolve] container to add
    # @raise [AlreadyRegistered] if given key already was used
    def add(key, container)
      raise AlreadyRegistered if key?(key)

      collection[key] = container
    end

    # Find container that was added with given key
    # @param key [Symbol] identifier for finding object
    # @return [#object] found container
    # @raise [UnknownEntity] if key wasn't registered
    def find(key)
      raise UnknownEntity unless key?(key)

      collection[key]
    end

    private

    def collection
      @collection ||= {}
    end

    def key?(key)
      collection.key?(key)
    end
  end
end
