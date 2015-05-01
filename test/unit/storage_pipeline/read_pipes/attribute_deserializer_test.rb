require 'test_helper'
require 'json'

module Pyper::ReadPipes
  class AttributeDeserializerTest < Minitest::Should::TestCase
    setup do
      type_mapping = {
                      :array => Array,
                      :hash => Hash,
                      :int => Integer,
                      :fixnum => Fixnum,
                      :other => String
                     }
      @pipe = AttributeDeserializer.new(type_mapping)
    end

    should 'deserialize json arrays' do
      value = [1,2,3]
      item = { :array => JSON.generate(value) }
      out = @pipe.pipe([item])
      assert_equal 1, out.count
      assert_equal value, out.first[:array]
    end

    should 'deserialize json hashes' do
      value = {'a' => 1}
      item = { :hash => JSON.generate(value) }
      out = @pipe.pipe([item])
      assert_equal 1, out.count
      assert_equal value, out.first[:hash]
    end

    should 'deserialize ints' do
      value = 1
      item = { :int => value.to_s }
      out = @pipe.pipe([item])
      assert_equal 1, out.count
      assert_equal value, out.first[:int]
    end

    should 'deserialize fixnums' do
      value = 1.5
      item = { :fixnum => value.to_s }
      out = @pipe.pipe([item])
      assert_equal 1, out.count
      assert_equal value, out.first[:fixnum]
    end

    should 'not deserialize other fields' do
      value = 'asdf'
      item = { :other => value }
      out = @pipe.pipe([item])
      assert_equal 1, out.count
      assert_equal value, out.first[:other]
    end
  end
end
