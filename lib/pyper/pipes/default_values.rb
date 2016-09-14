module Pyper::Pipes
  # @param default_values [Hash] A hash of default values to set within the provided attrs if they are not already present.
  class DefaultValues < Struct.new(:default_values)

    # @param attrs_or_items [Hash] The attributes of the item
    # @param status [Hash] The mutable status field
    # @return [Hash] The item attributes with default values inserted
    def pipe(attrs_or_items, status = {})
      case attrs_or_items
      when Hash then set_value(attrs_or_items)
      else attrs_or_items.map { |item| set_value(item) }
      end
    end

    # @param item the item whose attributes will be set to the default values
    # @return [Object] The object being modified
    def set_value(item)
      new_item = item.dup
      default_values.each do |field, value|
        new_item[field] = value unless new_item[field]
      end
      new_item
    end
  end
end
