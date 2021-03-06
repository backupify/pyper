require 'test_helper'

module Pyper::Pipes::Cassandra
  class ModKeyReaderTest < Minitest::Should::TestCase
    context 'a cassandra reader pipe' do

      setup do
        setup_cass_schema

        @client = create_cass_client('test_datastore')
        @pipe = ModKeyReader.new(:mod_test, @client, mod_size = 4)

        # populate some test data
        @client.insert(:mod_test, {row: 1, id: 'ida', mod_key: 0, val: '1'})
        @client.insert(:mod_test, {row: 1, id: 'idb', mod_key: 1, val: '2'})
        @client.insert(:mod_test, {row: 1, id: 'idc', mod_key: 2, val: '3'})
      end

      teardown do
        teardown_cass_schema
      end

      should 'return all items in an unordered enumerator from cassandra' do
        result = @pipe.pipe(row: 1).to_a
        assert_equal 3, result.size
        assert_equal %w(1 2 3).to_set, result.map { |i| i['val'] }.to_set
      end

      should 'page through cassandra result and return all items' do
        @client.insert(:mod_test, {row: 1, id: 'idd', mod_key: 0, val: '4'})
        @client.insert(:mod_test, {row: 1, id: 'ide', mod_key: 1, val: '5'})
        @client.insert(:mod_test, {row: 1, id: 'idf', mod_key: 2, val: '6'})

        paging_pipe = ModKeyReader.new(:mod_test, @client, mod_size = 4, page_size = 1)
        result = paging_pipe.pipe(row: 1).to_a
        assert_equal 6, result.size
        assert_equal %w(1 2 3 4 5 6).to_set, result.map { |i| i['val'] }.to_set
      end

      should 'not return items with a mod key outside the mod key range' do
        @client.insert(:mod_test, {row: 1, id: 'idz', mod_key: 4, val: '1'})
        result = @pipe.pipe(row: 1).to_a
        assert_equal 3, result.size
      end
    end
  end
end
