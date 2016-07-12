require 'test_helper'

module Pyper::Pipes
  class DefaultValuesTest < Minitest::Should::TestCase
    context 'the default values pipe' do

      setup do
        @pipe = DefaultValues.new(:a => 1, :c => 2)
      end

      should 'rename provided symbols as symbols' do
        assert_equal({ :a => 1, :c => 2 }, @pipe.pipe(:a => 2, :c => nil))
      end
    end
  end
end
