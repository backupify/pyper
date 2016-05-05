module Pyper::Pipes; end

# require the individual generic pipes
require_relative 'pipes/field_rename'
require_relative 'pipes/default_values'
require_relative 'pipes/no_op'
require_relative 'pipes/tap'
require_relative 'pipes/remove_fields'
require_relative 'pipes/force_enumerator'
