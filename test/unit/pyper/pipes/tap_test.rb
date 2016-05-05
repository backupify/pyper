require 'test_helper'

module Pyper
  module Pipes
    class TapTest < Minitest::Should::TestCase
      should "call the given block and return the original argument" do
        called = false
        res = Pyper::Pipeline.create do
          add -> (n, _) { n + 2 }
          add Pyper::Pipes::Tap.new { called = true }
          add -> (n, _) { n + 4 }
        end.push(1).value

        assert_equal 7, res
        assert called
      end

      should "yield the argument to the given block" do
        yielded = nil
        res = Pyper::Pipeline.create do
          add -> (n, _) { n + 2 }
          add Pyper::Pipes::Tap.new { |a| yielded = a }
          add -> (n, _) { n + 4 }
        end.push(1)

        assert_equal 3, yielded
      end
    end
  end
end
