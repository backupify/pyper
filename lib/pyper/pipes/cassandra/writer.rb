module Pyper::Pipes::Cassandra
  # Writes a set of attributes to a specified cassandra table.

  # @param table_name [Symbol] The table in which to store the attributes
  # @param client [Cassava::Client] client to query cassandra with
  # @param attribute_filter_set [Set] Optionally, a set of attributes which should be written. If none is provided,
  #   all attributes will be written.
  class Writer < Struct.new(:table_name, :client, :attribute_filter_set)

    # @param args [Hash] Arguments to store in cassandra
    # @param status [Hash] The mutable status field
    # @return [Hash] The original attributes
    def pipe(attributes, status = {})
      attributes_to_write = if attribute_filter_set
                              attributes.select { |k,v| attribute_filter_set.member?(k) }
                            else
                              attributes
                            end

      ttl = attributes_to_write.delete(:ttl)
      client.insert(table_name, attributes_to_write, ttl)
      attributes
    end
  end
end
