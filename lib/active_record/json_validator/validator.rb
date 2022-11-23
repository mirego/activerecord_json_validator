# frozen_string_literal: true

class JsonValidator < ActiveModel::EachValidator
  def initialize(options)
    options.reverse_merge!(message: :invalid_json)
    options.reverse_merge!(schema: nil)
    options.reverse_merge!(options: {})
    @attributes = options[:attributes]

    super

    inject_setter_method(options[:class], @attributes)
  end

  # Validate the JSON value with a JSON schema path or String
  def validate_each(record, attribute, _value)
    # Get the _actual_ attribute value, not the getter method value
    value = record[attribute]

    # Validate value with JSON Schemer
    errors = JSONSchemer.schema(schema(record), **options.fetch(:options)).validate(value).to_a

    # Everything is good if we don’t have any errors and we got valid JSON value
    return if errors.empty? && record.send(:"#{attribute}_invalid_json").blank?

    # Add error message to the attribute
    message(errors).each do |error|
      error = error.is_a?(Hash) ? JSONSchemer::Errors.pretty(error) : error
      record.errors.add(attribute, error, value: value)
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

  # Return a valid schema, recursively calling
  # itself until it gets a non-Proc/non-Symbol value.
  def schema(record, schema = nil)
    schema ||= options.fetch(:schema)

    case schema
      when Proc then schema(record, record.instance_exec(&schema))
      when Symbol then schema(record, record.send(schema))
      else schema
    end
  end

  def message(errors)
    message = options.fetch(:message)

    case message
      when Proc then [message.call(errors)].flatten if message.is_a?(Proc)
      else [message]
    end
  end
end
