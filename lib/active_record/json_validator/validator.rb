class JsonValidator < ActiveModel::EachValidator
  def initialize(options)
    options.reverse_merge!(message: :invalid_json)
    options.reverse_merge!(schema: nil)

    super
  end

  def validate_each(record, attribute, value)
    json_value = JSON.dump(value)
    errors = ::JSON::Validator.fully_validate(options.fetch(:schema), json_value)

    if errors.any?
      record.errors.add(attribute, options.fetch(:message), value: value)
    end
  end
end
