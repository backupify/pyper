require_relative '../../../test_helper'

module Pyper::WritePipes
  class IfNotExistsCassandraWriterTest < Minitest::Should::TestCase
    context 'a cassandra writer pipe' do

      setup do
        setup_cass_schema

        @client = create_cass_client('test_datastore')
        @writer = IfNotExistsCassandraWriter.new(:test, @client)
      end

      teardown do
        teardown_cass_schema
      end
      context "standard insert" do
        should 'write to the specified cassandra table' do
          # setup insert
          attributes = {id: 'id', a: 'a', b: 'b'}
          @writer.pipe(attributes)
          row = @client.select(:test).execute.first

          attributes.keys.each do |key|
            assert_equal attributes[key], row[key.to_s]
          end
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
        writer = CassandraWriter.new(:test, @client, filter)
        assert_equal attributes, writer.pipe(attributes)
      end
    end
  end
end
