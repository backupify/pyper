require 'test_helper'

module Pyper::Pipes::Cassandra
  class ReaderTest < Minitest::Should::TestCase
    context 'a cassandra reader pipe' do

      setup do
        setup_cass_schema

        @client = create_cass_client('test_datastore')
        @pipe = Reader.new(:test, @client)

        # populate some test data
        @client.insert(:test, {id: 'id', a: '1', b: 'b'})
        @client.insert(:test, {id: 'id', a: '2', b: 'b'})
      end

      teardown do
        teardown_cass_schema
      end

      should 'read items from the cassandra table' do
        out = @pipe.pipe(id: 'id').to_a
        assert_equal 2, out.count
        assert_equal({ "id" => "id", "a" => "1", "b" => "b" }, out.first)
      end

      should 'return items in ascending order' do
        out = @pipe.pipe(id: 'id').to_a
        assert_equal %w(1 2), out.map { |i| i['a'] }
      end

      should 'limit results if limit arg provided' do
        out = @pipe.pipe(id: 'id', :limit => 1).to_a
        assert_equal 1, out.count
      end

      should 'order results by field and direction if order pair provided' do
        out = @pipe.pipe(id: 'id', :order => [:a, :desc]).to_a
        assert_equal %w(2 1), out.map { |i| i['a'] }
      end

      should 'save page state and last_page in status' do
        status = {}
        out = @pipe.pipe({id: 'id', :page_size => 1}, status).to_a
        assert_equal 1, out.count
        assert_equal '1', out.first['a']
        assert status[:paging_state]
        assert_equal false, status[:last_page]
      end

      should 'page through results if :page_size and/or :paging_state provided' do
        status = {}
        out = @pipe.pipe({id: 'id', :page_size => 1}, status).to_a
        assert_equal 1, out.count
        assert_equal '1', out.first['a']
        paging_state = status[:paging_state]

        out = @pipe.pipe({id: 'id', :page_size => 1, :paging_state => paging_state}, status).to_a
        assert_equal 1, out.count
        assert_equal '2', out.first['a']
        assert_equal false, status[:last_page]
      end

      should "allow custom consistency to be passed for a single request" do
        original_opts = @pipe.client.session.instance_variable_get(:@options)
        refute_equal original_opts.consistency, :all

        expected_opts_with_all = original_opts.override(:consistency => :all, :arguments => ["id"])
        original_opts.expects(:override).with { |opts| opts[:consistency] == :all }.returns(expected_opts_with_all)

        out = @pipe.pipe({id: 'id', :consistency => :all}, {})
        assert_equal 2, out.count
      end

      context "columns selecting" do
        should "only select given columns from columns argument" do
          out = @pipe.pipe({id: 'id', :columns => [:a]}).to_a
          assert_equal({'a' => '1'}, out.first)
          assert_equal({'a' => '2'}, out.last)
        end

        should  "select all columns when columns argument not given" do
          out = @pipe.pipe({id: 'id'}).to_a
          assert_equal({ "id" => "id", "a" => "1", "b" => "b" }, out.first)
        end
      end
    end
  end
end
