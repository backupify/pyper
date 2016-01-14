module Pyper::Pipes::Cassandra
  # A pipe for reading all items from a single row in cassandra
  # @param [Symbol] table name
  # @param [Cassava::Client] client to query cassandra with
  class AllItemsReader < Struct.new(:table, :client)
    attr_reader :page_size

    # @param table [Symbol] the name of the cassandra table to fetch data from
    # @param client [Cassava::Client]
    # @param mod_size [Integer] the mod size
    # @param page_size [Integer] the page size
    def initialize(table, client, page_size = 1000)
      @table = table
      @client = client
      @page_size = page_size
    end

    # @param arguments [Hash] Arguments passed to the cassandra client where statement
    # @option arguments [Array] :order A pair [clustering_column, :desc|:asc] determining how to order the results.
    # @option arguments [Integer] :page_size
    # @param status [Hash] The mutable status field
    # @return [Enumerator::Lazy<Hash>] enumerator of items
    def pipe(arguments, status = {})
      columns = arguments.delete(:columns)
      enum = Enumerator.new do |yielder|
        options = { :page_size => page_size }
        paging_state = nil
        loop do
          options[:paging_state] = paging_state if paging_state.present?
          result = @client.select(@table, columns).where(arguments).execute(options)
          result.each { |item| yielder << item }

          break if result.last_page?
          paging_state = result.paging_state
        end
      end
      enum.lazy
    end
  end
end
