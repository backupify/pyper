module Pyper::WritePipes
  class IfNotExistsCassandraWriter < Struct.new(:table_name, :client, :attribute_filter_set)
    def pipe(attributes, status = {})
      attributes_to_write = if attribute_filter_set
                              attributes.select { |k,v| attribute_filter_set.member?(k) }
                            else
                              attributes
                            end

      result = client.insert(table_name, attributes_to_write, { :if_not_exists => true })
      if results.first["[applied]"] == false
        old_record = results.first
        old_record.delete("[applied]")
        status["old_record"] = old_record
      end
      attributes
    end
  end
end
