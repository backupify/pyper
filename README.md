# Pyper

Flexible pipelines for content storage and retrieval.

Pyper allows the construction of pipelines to store and retrieve data. Each pipe in the pipeline modifies the
information in the pipeline before passing it to the next step. By composing pipes in different ways, different
data access patterns can be created.

## Usage

Require the pyper library and the pipes that you need:

```ruby
require 'pyper'
require 'pyper/model'      # Import model-related pipes
require 'pyper/cassandra'  # Import Cassandra-related pipes
require 'pyper/content'    # Import content storage-related pipes
```

Or, import the entire library using `require 'pyper/all'`

Create a pipeline composed of a set of pipes:

```ruby
write_pipeline = Pyper::Pipeline.create do
   add Pyper::Pipes::Write::AttributeSerializer.new
   add Pyper::Pipes::FieldRename.new(:to => :to_emails, :from => :from_email)
   add Pyper::Pipes::ModKey.new
   add Pyper::Pipes::Cassandra::Writer.new(:table_1, metadata_client)
   add Pyper::Pipes::Cassandra::Writer.new(:table_2, indexes_client)
   add Pyper::Pipes::Cassandra::Writer.new(:table_3, indexes_client)
end
```

Then, push data down the pipe:

```ruby
result = write_pipeline.push(attributes)
```

View the value of the set of successive transformations performed by the pipe:
```ruby
result.value
```

A pipeline performs a bunch of sequential transformations to the data being passed down the pipe. It may also have side
effects, such as storing data. The specific pipes provided in this library aim are aimed at two uses: writing and
reading data.

A write pipeline takes an initial set of attributes, performing a set of transfomations such as serialization and so on,
before storing the data in one or more storage outputs. For example, this gem provides storage pipes for Cassandra and
Amazon S3, but it is easy to write a pipe for other storage backends.

Conversely, a read pipeline takes initially a set of options. These options be transformed by the pipeline, and then used
to read data from an external source. This data may then be transformed by the pipeline - for example, performing
deserialization or data mapping operations.

```ruby
read_pipeline = Pyper::Pipeline.create do
   add Pyper::Pipes::Cassandra::PaginationDecoding.new
   add Pyper::Pipes::Cassandra::Reader.new(:table, indexes_client)
   add Pyper::Pipes::FieldRename.new(:to_emails => :to, :from_email => :from)
   add Pyper::Pipes::Cassandra::PaginationEncoding.new
   add Pyper::Pipes::Model::VirtusDeserializer.new(message_attributes)
   add Pyper::Pipes::Model::VirtusParser.new(MyModelClass)
end

result = read_pipeline.push(:row => '1', :id => 'i', :page_token => 'sdf')
result.value # Enumerator with matching instances of MyModelClass
```

Note that pipe order matters. In the example read pipe above, `Cassandra::PaginationDecoding` decodes pagination options, thus
performing an operation on the initial options provided. The `Cassandra::Reader` pipe uses the options to retrieve items from
Cassandra, and subsequent elements of the pipeline are designed to transform this retrieved data. Thus, it would not be
sensible for the `Cassandra::PaginationDecoding` pipe to come after the `Cassandra::Reader` pipe.

### Creating and using pipelines

A pipeline is an instance of `Pyper::Pipeline`, to which pipes are appended using the `<<` or `add` operators.

```ruby
my_pipeline = Pyper::Pipeline.new <<
   Pyper::Pipes::Cassandra::PaginationDecoding.new <<
   Pyper::Pipes::Cassandra::Reader.new(:table, indexes_client) <<
   Pyper::Pipes::Cassandra::PaginationEncoding.new
```

However, the `create` method makes pipeline construction easier. The above example becomes the following:

```ruby
my_pipeline = Pyper::Pipeline.create do
   add Pyper::Pipes::Cassandra::PaginationDecoding.new
   add Pyper::Pipes::Cassandra::Reader.new(:table, indexes_client)
   add Pyper::Pipes::Cassandra::PaginationEncoding.new
end
```

To invoke the pipeline, use the `push` method and provide the data to enter the pipeline:

```ruby
pipe_status = my_pipeline.push(:row => '1', :id => 'i')
```

Here, `pipe_status` is a `Pyper::PipeStatus` object, which contains two attributes, `pipe_status.value` and
`pipe_status.status`. The value is the returned result of the series of tranformations applied by the pipeline. The status
contains metadata about the push operation that might be created by each pipe in the pipeline.

### Creating new pipes

A pipe must implement the `call` method, which takes two arguments: the object entering the pipe, as well as the status. It
should return the object leaving the pipe:

```ruby
class MyPipe
  def call(attributes, status = {})
    attributes[:c] = attributes[:a] + attributes[:b]
    status[:processed_by_my_pipe] = true
    attributes
  end
end
```

This example pipe above modifies `attributes` before returning it. It also sets a flag on the status object.

Note that because the pipe need only respond to `call`, lambdas and procs are valid pipes.

Generally, pipes in a write pipeline operate on an attributes hash (containing the attributes meant to be written to a data
store). Pipes in a read pipeline initially might modify arguments. A data retrieval pipe would then use the arguments to
fetch data, and subsequent pipes would perform operations on the enumeration of data items. Thus, a read pipe might look
something like:

```ruby
class Deserialize
  def call(items, status = {})
     items.map { |item| deserialize(item) }
  end

  def deserialize(item)
    ...
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pyper_rb', :git => 'git@github.com:backupify/pyper.git'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pyper_rb

## Contributing

1. Fork it ( https://github.com/backupify/pyper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
