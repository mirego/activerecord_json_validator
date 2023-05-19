# frozen_string_literal: true

class JsonValidator < ActiveModel::EachValidator
  def initialize(options)
    options.reverse_merge!(message: :invalid_json)
    options.reverse_merge!(schema: nil)
    options.reverse_merge!(options: {})
    options.reverse_merge!(value: ->(_record, _attribute, value) { value })
    @attributes = options[:attributes]

    super

    inject_setter_method(options[:class], @attributes)
  end

  # Validate the JSON value with a JSON schema path or String
  def validate_each(record, attribute, value)
    # Get the _actual_ attribute value, not the getter method value
    value = options.fetch(:value).call(record, attribute, value)

    # Validate value with JSON Schemer
    errors = JSONSchemer.schema(schema(record), **options.fetch(:options)).validate(value).to_a

    # Everything is good if we don’t have any errors and we got valid JSON value
    return if errors.empty? && record.send(:"#{attribute}_invalid_json").blank?

    # Add error message to the attribute
    details = errors.map { |e| JSONSchemer::Errors.pretty(e) }
    message(errors).each do |error|
      error = JSONSchemer::Errors.pretty(error) if error.is_a?(Hash)
      record.errors.add(attribute, error, errors: details, value: value)
    end
  end

protected

  # Redefine the setter method for the attributes, since we want to
  # catch JSON parsing errors.
  def inject_setter_method(klass, attributes)
    return if klass.nil?

    attributes.each do |attribute|
      klass.prepend(Module.new do
        attr_reader :"#{attribute}_invalid_json"

        define_method "#{attribute}=" do |args|
          begin
            instance_variable_set("@#{attribute}_invalid_json", nil)
            args = ::ActiveSupport::JSON.decode(args) if args.is_a?(::String)
            super(args)
          rescue ActiveSupport::JSON.parse_error
            instance_variable_set("@#{attribute}_invalid_json", args)
            super({})
          end
        end
      end)
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
    message = message.call(errors) if message.is_a?(Proc)
    [message].flatten
  end
end
