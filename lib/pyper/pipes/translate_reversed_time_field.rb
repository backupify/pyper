module Pyper::Pipes
  # Cassandra sometimes has issues sorting in descending order, meaning that timestamp fields will not work well
  # for most-recent-first accessing of data. Instead, we can use a reversed integer field to achieve the same result.
  # This pipe translates between those two formats.
  # See https://issues.apache.org/jira/browse/CASSANDRA-7867 for more info.
  # @param [Array] A list of date fields which should be encoded as reversed (negative) integers
  class TranslateReversedTimeField

    attr_reader :time_fields

    def initialize(*args)
      @time_fields = *args
    end

    # @param [Hash|Enumerator] A set of attrs containing the time field(s) to be encoded, or an Enumerator of items,
    # each of which has the time field(s) to be decoded.
    def pipe(attrs_or_items, status = {})
      case attrs_or_items
      when Hash then encode(attrs_or_items)
      else decode(attrs_or_items)
      end
    end

    def encode(attrs)
      time_fields.each do |field|
        attrs[field] = -attrs[field].to_i if attrs.has_key?(field)
      end
      attrs
    end

    def decode(items)
      items.map do |item|
        time_fields.each do |field|
          item[field] = Time.at(-item[field]) if item.has_key?(field)
        end
        item
      end
    end
  end
end
