class JsonValidator < ActiveModel::EachValidator

  class << self
    attr_writer :schema_method

    def schema_method
      @schema_method || "_json_schema"
    end
  end
  

  def initialize(options)
    @options = options
    @options.reverse_merge!(message: :invalid_json)
    @options.reverse_merge!(schema: nil)
    @attributes = options[:attributes]

    super

    # Rails 4.1 and above expose a `class` option
    if options[:class]
      inject_setter_method(options[:class], @attributes)

    # Rails 4.0 and below calls a `#setup` method
    elsif !respond_to?(:setup)
      class_eval do
        define_method :setup do |model|
          inject_setter_method(model, @attributes)
        end
      end
    end
  end

  # Validate the JSON value with a JSON schema path or String
  def validate_each(record, attribute, value)
    @record = record

    begin
      json_value = JSON.dump(value)
    rescue JSON::GeneratorError
      json_value = ''
    end

    errors = ::JSON::Validator.fully_validate(schema, json_value)

    if errors.any? || record.send(:"#{attribute}_invalid_json").present?
      record.errors.add(attribute, @options.fetch(:message), value: value)
    end
  end

protected

  def schema
    if @record.respond_to? self.class.schema_method
      @record.send self.class.schema_method
    else
      @options.fetch(:schema)
    end
  end

  # Redefine the setter method for the attributes, since we want to
  # catch any MultiJson::LoadError errors.
  def inject_setter_method(klass, attributes)
    attributes.each do |attribute|
      klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        attr_reader :"#{attribute}_invalid_json"

        define_method "#{attribute}=" do |args|
          begin
            @#{attribute}_invalid_json = nil
            args = ::ActiveSupport::JSON.decode(args) if args.is_a?(::String)
            super(args)
          rescue MultiJson::LoadError, JSON::ParserError
            @#{attribute}_invalid_json = args
            super(invalid_json: true)
          end
        end
      RUBY
    end
  end
end
