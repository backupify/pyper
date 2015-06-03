require_relative '../../../test_helper'

module Pyper::Pipes
  class TranslateReversedTimeFieldTest < Minitest::Should::TestCase
    context 'the reversed time field pipe' do

      setup do
        @pipe = TranslateReversedTimeField.new(:time, :time2)
      end

      context 'encoding attr objects' do
        should 'encode provided fields' do
          time = Time.now
          encoded = -time.to_i
          assert_equal({ :time => encoded }, @pipe.pipe(:time => time))
        end

        should 'not encode other fields' do
          time = Time.now
          assert_equal({ :other => time }, @pipe.pipe(:other => time))
        end
      end

      context 'decoding item lists' do
        should 'decode time fields' do
          time = Time.now
          encoded = -time.to_i
          decoded_array = @pipe.pipe([{:time => encoded}])
          assert_equal(1, decoded_array.count)
          assert_equal(1, decoded_array.first.keys.count)
          assert_equal(Time, decoded_array.first[:time].class)
          assert_equal(-encoded, decoded_array.first[:time].to_i)
        end

        should 'not decode other fields' do
          encoded = -1
          assert_equal([{:other => encoded}], @pipe.pipe([{:other => encoded}]))
        end
      end
    end
  end
end
