class JsonValidator < ActiveModel::EachValidator
  def initialize(options)
    options.reverse_merge!(message: :invalid_json)
    options.reverse_merge!(schema: nil)
    @attributes = options[:attributes]

    super
  end

  # Redefine the setter method for the attributes, since we want to
  # catch any MultiJson::LoadError errors.
  def setup(model)
    @attributes.each do |attribute|
      model.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        define_method "#{attribute}=" do |args|
          begin
            @_#{attribute}_sane_json = true
            super(args)
          rescue MultiJson::LoadError
            @_#{attribute}_sane_json = false
            super({})
          end
        end
      RUBY
    end
  end

  # Validate the JSON value with a JSON schema path or String
  def validate_each(record, attribute, value)
    json_value = JSON.dump(value)
    errors = ::JSON::Validator.fully_validate(options.fetch(:schema), json_value)

    if errors.any? || instance_variable_get(:"@_#{attribute}_sane_json") == false
      record.errors.add(attribute, options.fetch(:message), value: value)
    end
  end
end
