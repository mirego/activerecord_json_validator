class JsonValidator < ActiveModel::EachValidator
  def initialize(options)
    options.reverse_merge!(message: :invalid_json)
    options.reverse_merge!(schema: nil)
    options.reverse_merge!(options: { errors_as_objects: true })
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
    # Validate value with JSON::Validator
    errors = ::JSON::Validator.fully_validate(schema(record), validatable_value(value), options.fetch(:options))

    # Everything is good if we don’t have any errors and we got valid JSON value
    return if errors.empty? && record.send(:"#{attribute}_invalid_json").blank?

    # Add error message to the attribute
    message = options.fetch(:message)
    errors.each do |error|
      if message == :invalid_json && error.is_a?(String) # default
        record.errors.add(attribute, message, value: value)
      else
        record.errors.add(attribute, error.is_a?(String) ? error : error.fetch(:message))
      end
    end
  end

protected

  # Redefine the setter method for the attributes, since we want to
  # catch JSON parsing errors.
  def inject_setter_method(klass, attributes)
    attributes.each do |attribute|
      klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        attr_reader :"#{attribute}_invalid_json"

        define_method "#{attribute}=" do |args|
          begin
            @#{attribute}_invalid_json = nil
            args = ::ActiveSupport::JSON.decode(args) if args.is_a?(::String)
            super(args)
          rescue ActiveSupport::JSON.parse_error
            @#{attribute}_invalid_json = args
            super({})
          end
        end
      RUBY
    end
  end

  # Return a valid schema for JSON::Validator.fully_validate, recursively calling
  # itself until it gets a non-Proc/non-Symbol value.
  def schema(record, schema = nil)
    schema ||= options.fetch(:schema)

    case schema
      when Proc then schema(record, record.instance_exec(&schema))
      when Symbol then schema(record, record.send(schema))
      else schema
    end
  end

  def validatable_value(value)
    return value if value.is_a?(String)
    ::ActiveSupport::JSON.encode(value)
  end
end
