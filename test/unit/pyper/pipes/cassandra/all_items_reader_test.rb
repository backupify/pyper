require 'test_helper'

module Pyper::Pipes::Cassandra
  class AllItemsReaderTest < Minitest::Should::TestCase
    context 'a cassandra paging_reader pipe' do
      setup do
        setup_cass_schema

        @client = create_cass_client('test_datastore')
        @pipe = AllItemsReader.new(:test, @client)

        # populate some test data
        @client.insert(:test, {id: 'ida', a: '1', b: '2'})
        @client.insert(:test, {id: 'ida', a: '2', b: '3'})
        @client.insert(:test, {id: 'ida', a: '3', b: '4'})
        @client.insert(:test, {id: 'idb', a: '1', b: '2'})
        @client.insert(:test, {id: 'idb', a: '2', b: '3'})
      end

      teardown do
        teardown_cass_schema
      end

      should 'page through cassandra result and return all items' do
        @client.insert(:test, {id: 'ida', a: '4', b: '4'})

        all_items = AllItemsReader.new(:test, @client)
        result = all_items.pipe(id: 'ida').to_a
        assert_equal 4, result.size
        assert_equal %w(1 2 3 4).to_set, result.map { |i| i['a'] }.to_set
      end

      context "columns selecting" do
        should "only select given columns from columns argument" do
          out = @pipe.pipe({id: 'idb', :columns => [:a]}).to_a
          assert_equal({'a' => '1'}, out.first)
          assert_equal({'a' => '2'}, out.last)
        end

        should  "select all columns when columns argument not given" do
          out = @pipe.pipe({id: 'idb'}).to_a
          assert_equal({ "id" => "idb", "a" => "1", "b" => "2" }, out.first)
        end
      end
    end
  end
end
