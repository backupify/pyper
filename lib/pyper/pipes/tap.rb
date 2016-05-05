module Pyper::Pipes
  class Tap
    def initialize(&block)
      @block = block
    end

    def call(arg, _status)
      arg.tap(&@block)
    end
  end
end
