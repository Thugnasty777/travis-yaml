module Travis
  module Yaml
    Error      ||= Class.new(StandardError)
    ParseError ||= Class.new(Error)

    require 'travis/yaml/secure_string'
    require 'travis/yaml/nodes'
    require 'travis/yaml/matrix'
    require 'travis/yaml/parser'
    require 'travis/yaml/serializer'

    extend self

    def parse(value)
      result = Parser.parse(value)
      yield result if block_given?
      result
    end

    alias load parse

    def parse!(value, file_name = '.travis.yml', &block)
      result = parse(value, &block)
      result.nested_warnings.each do |key, message|
        warn if key.empty?
  "#{file_name}: #{message}"
else
  "#{file_name}: #{key.join('.')} section - #{message}"
end
      end
      result
    end

    def new
      root = Nodes::Root.new
      yield root if block_given?
      root.deep_verify
      root
    end

    def matrix(value)
      Matrix.new parse(value)
    end

    def matrix!(value, file_name = '.travis.yml')
      Matrix.new parse!(value, file_name)
    end
  end
end
