module Pyper::Pipes::Cassandra
  # A pipe for reading items from a single row in cassandra
  # @param [Symbol] table name
  # @param [Cassava::Client] client to query cassandra with
  # @param [Hash] Additional/default options to pass to the Cassava execute statement.
  class Reader < Struct.new(:table, :client, :options)
    # @param arguments [Hash] Arguments passed to the cassandra client where statement
    # @option arguments [Integer] :limit
    # @option arguments [Array] :order A pair [clustering_column, :desc|:asc] determining how to order the results.
    # @option arguments [Object] :paging_state
    # @option arguments [Integer] :page_size
    # @option arguments [Symbol] :consistency The consistency for the request. Must be
    #   one of Cassandra::CONSISTENCIES.
    # @param status [Hash] The mutable status field
    # @return [Enumerator::Lazy<Hash>] enumerator of items
    def pipe(arguments, status = {})
      limit = arguments.delete(:limit)
      page_size = arguments.delete(:page_size)
      paging_state = arguments.delete(:paging_state)
      order = arguments.delete(:order)
      columns = arguments.delete(:columns)
      consistency = arguments.delete(:consistency)
      where = arguments.delete(:where)
      allow_filtering = arguments.delete(:allow_filtering)

      opts = options.nil? ? {} : options.dup
      opts[:page_size] = page_size if page_size
      opts[:paging_state] = paging_state if paging_state
      opts[:consistency] = consistency if consistency

      query = client.select(table, columns)
      query = query.where(arguments) if arguments.any? # backwards-compatibility -- it should be preferred to pass in `:where`
      where.each { |clause| query = query.where(*clause) } if where.present?

      query = query.limit(limit) if limit
      query = query.order(order.first, order.last) if order
      query = query.allow_filtering if allow_filtering
      result = query.execute(opts)

      status[:paging_state] = result.paging_state
      status[:last_page] = result.last_page?

      result.rows.lazy
    end
  end
end
