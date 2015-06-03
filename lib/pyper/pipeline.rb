require 'active_support/core_ext/hash' # indifferent access

require_relative 'write_pipes/cassandra_writer'
require_relative 'write_pipes/attribute_serializer'
require_relative 'write_pipes/content_storage'

require_relative 'read_pipes/content_fetch'
require_relative 'read_pipes/cassandra_items'
require_relative 'read_pipes/attribute_deserializer'
require_relative 'read_pipes/virtus_deserializer'
require_relative 'read_pipes/virtus_parser'
require_relative 'read_pipes/cass_mod_key_enumerator'
require_relative 'read_pipes/pagination_decoding'
require_relative 'read_pipes/pagination_encoding'
require_relative 'read_pipes/force_enumerator'

# pipes that can be used for both reading and writing
require_relative 'pipes/mod_key'
require_relative 'pipes/field_rename'
require_relative 'pipes/default_values'
require_relative 'pipes/translate_reversed_time_field'

module Pyper

  class PipeStatus < Struct.new(:value, :status); end

  class Pipeline
    attr_reader :pipes
    def initialize(pipes = [])
      @pipes = pipes
    end

    # @param [#pipe] A pipe to append to the pipeline
    def <<(pipe)
      pipes << pipe
      self
    end

    # Insert something into the pipeline to be processed
    # @param [Object] The original input data to enter the pipeline. This may be mutated by each pipe in the pipeline.
    # @param [Hash] A status hash that may be updated by the pipeline
    def push(input)
      status = {}
      value = pipes.inject(input) { |attributes, p| p.pipe(attributes, status) }
      PipeStatus.new(value, status)
    end
  end
end
