module RuntimeTypes
  class Function
    def initialize(&callback)
      @callback = callback
    end

    def call(args)
      @callback.call(*args)
    end
  end
end
