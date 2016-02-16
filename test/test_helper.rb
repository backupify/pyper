require 'rubygems'
require 'pry'
require 'minitest/autorun'
require 'minitest/should'
require 'mocha/api'

class Minitest::Should::TestCase
  def self.xshould(*args)
    puts "Disabled test: #{args}"
  end
end

def setup_cass_schema
  base_path = "#{File.dirname(__FILE__)}/fixtures"
  ::CassSchema::Runner.datastores = ::CassSchema::YamlHelper.datastores(File.join(base_path, 'cass_schema_config.yml'))
  ::CassSchema::Runner.schema_base_path = base_path
  ::CassSchema::Runner.create_all
end

def teardown_cass_schema
  ::CassSchema::Runner.drop_all
end

def create_cass_client(datastore_name)
  keyspace = ::CassSchema::Runner.datastore_lookup(datastore_name).keyspace
  c = Cassandra.cluster(port: 9242)
  session = c.connect(keyspace)
  Cassava::Client.new(session)
end


require 'pyper/all'
require 'storage_strategy'
require 'cass_schema'
require 'cassava'
