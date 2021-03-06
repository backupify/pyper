require 'test_helper'

module Pyper::Pipes
  class DefaultValuesTest < Minitest::Should::TestCase
    context 'the default values pipe' do

      setup do
        @pipe = DefaultValues.new(:a => 10, :c => 20)
      end

      should 'set default values properly' do
        assert_equal({ :a => 2, :b => 3, :c => 20 }, @pipe.pipe(:a => 2, :b => 3, :c => nil))
      end

      should 'work if the passed in values are a in a lazy enumerator' do
        assert_equal([{ :a => 2, :b => nil, :c => 1 }, { :a => 1, :b => 3, :c => 20 }],
                     @pipe.pipe([{ :a => 2, :b => nil, :c => 1 }, { :a => 1, :b => 3, :c => nil }].lazy).to_a)
      end
    end
  end
end
