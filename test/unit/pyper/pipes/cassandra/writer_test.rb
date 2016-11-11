require 'test_helper'

module Pyper::Pipes::Cassandra
  class WriterTest < Minitest::Should::TestCase
    context 'a cassandra writer pipe' do

      setup do
        setup_cass_schema

        @client = create_cass_client('test_datastore')
        @writer = Writer.new(:test, @client)
      end

      teardown do
        teardown_cass_schema
      end

      should 'write to the specified cassandra table' do
        attributes = {id: 'id', a: 'a', b: 'b'}
        @writer.pipe(attributes)
        row = @client.select(:test).execute.first

        attributes.keys.each do |key|
          assert_equal attributes[key], row[key.to_s]
        end
      end

      should 'raise an error if required attributes are not provided' do
        attributes = {a: 'a', b: 'b'}
        assert_raises(Cassandra::Errors::InvalidError) { @writer.pipe(attributes) }
      end

      should 'return the original attributes if the write succeeds' do
        attributes = {id: 'id', a: 'a', b: 'b'}
        assert_equal attributes, @writer.pipe(attributes)
      end

      should 'raise an error if too many attributes are provided' do
        attributes = {id: 'id', a: 'a', b: 'b', not_an_attribute: 'x'}
        assert_raises(Cassandra::Errors::InvalidError) { @writer.pipe(attributes) }
      end

      should 'filter attributes if a filter set is given, returning the original attributes' do
        attributes = {id: 'id', a: 'a', b: 'b', not_an_attribute: 'x'}
        filter = [:id, :a, :b]
        writer = Writer.new(:test, @client, filter)
        assert_equal attributes, writer.pipe(attributes)
      end

      should 'allow a TTL to be passed into the pipe' do
        attributes = {id: 'id', a: 'a', b: 'b', ttl: 12345}
        filter = [:id, :a, :b, :ttl]
        ttl = attributes[:ttl]
        expected_attributes = attributes.dup
        expected_attributes.delete(:ttl)

        writer = Writer.new(:test, @client, filter)
        writer.client.expects(:insert).with(:test, expected_attributes, ttl)
        assert_equal attributes, writer.pipe(attributes)
      end
    end
  end
end
