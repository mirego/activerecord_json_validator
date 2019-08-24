# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
require 'spec_helper'

describe JsonValidator do
  describe :initialize do
    # NOTE: We do not explicitely call `JsonValidator.new` in the tests,
    # because we let Rails (ActiveModel::Validations) do that when we call
    # `validates … json: true` on the model.
    #
    # This allows us to test the constructor behavior when executed in
    # different Rails versions that do not pass the same arguments to it.
    before do
      run_migration do
        create_table(:users, force: true) do |t|
          t.string :name
          t.text :data
        end
      end

      spawn_model 'User' do
        serialize :data, JSON
        validates :data, json: true
      end

      record.data = data
    end

    let(:record) { User.new }

    context 'with valid JSON data' do
      let(:data) { 'What? This is not JSON at all.' }
      it { expect(record.data_invalid_json).to eql(data) }
    end

    context 'with invalid JSON data' do
      let(:data) { { foo: 'bar' } }
      it { expect(record.data_invalid_json).to be_nil }
    end
  end

  describe :validate_each do
    let(:validator) { JsonValidator.new(options) }
    let(:options) { { attributes: [attribute], options: { strict: true } } }
    let(:validate_each!) { validator.validate_each(record, attribute, value) }

    # Doubles
    let(:attribute) { double(:attribute, to_s: 'attribute_name') }
    let(:record) { double(:record, errors: record_errors) }
    let(:record_errors) { double(:errors) }
    let(:value) { double(:value) }
    let(:schema) { double(:schema) }
    let(:validatable_value) { double(:validatable_value) }
    let(:validator_errors) { double(:validator_errors) }

    before do
      expect(validator).to receive(:schema).with(record).and_return(schema)
      expect(validator).to receive(:validatable_value).with(value).and_return(validatable_value)
      expect(::JSON::Validator).to receive(:fully_validate).with(schema, validatable_value, options[:options]).and_return(validator_errors)
    end

    context 'with JSON::Validator errors' do
      before do
        expect(validator_errors).to receive(:empty?).and_return(false)
        expect(record).not_to receive(:"#{attribute}_invalid_json")
        expect(record_errors).to receive(:add).with(attribute, options[:message], value: value)
      end

      specify { validate_each! }
    end

    context 'without JSON::Validator errors but with invalid JSON data' do
      before do
        expect(validator_errors).to receive(:empty?).and_return(true)
        expect(record).to receive(:"#{attribute}_invalid_json").and_return('foo"{]')
        expect(record_errors).to receive(:add).with(attribute, options[:message], value: value)
      end

      specify { validate_each! }
    end

    context 'without JSON::Validator errors and valid JSON data' do
      before do
        expect(validator_errors).to receive(:empty?).and_return(true)
        expect(record).to receive(:"#{attribute}_invalid_json").and_return(nil)
        expect(record_errors).not_to receive(:add)
      end

      specify { validate_each! }
    end

    context 'with multiple error messages' do
      let(:options) { { attributes: [attribute], message: message, options: { strict: true } } }
      let(:message) { ->(errors) { errors.to_a } }

      before do
        expect(validator_errors).to receive(:empty?).and_return(false)
        expect(validator_errors).to receive(:to_a).and_return(%i[first_error second_error])
        expect(record).not_to receive(:"#{attribute}_invalid_json")
        expect(record_errors).to receive(:add).with(attribute, :first_error, value: value)
        expect(record_errors).to receive(:add).with(attribute, :second_error, value: value)
      end

      specify { validate_each! }
    end
  end

  describe :schema do
    let(:validator) { JsonValidator.new(options) }
    let(:options) { { attributes: [:foo], schema: schema_option } }
    let(:schema) { validator.send(:schema, record) }

    context 'with String schema' do
      let(:schema_option) { double(:schema) }
      let(:record) { double(:record) }

      it { expect(schema).to eql(schema_option) }
    end

    context 'with Proc schema returning a Proc returning a Proc' do
      let(:schema_option) { -> { dynamic_schema } }
      let(:record) { record_class.new }
      let(:record_class) do
        Class.new do
          def dynamic_schema
            -> { another_dynamic_schema }
          end

          def another_dynamic_schema
            -> { what_another_dynamic_schema }
          end

          def what_another_dynamic_schema
            'yay'
          end
        end
      end

      it { expect(schema).to eql('yay') }
    end

    context 'with Symbol schema' do
      let(:schema_option) { :dynamic_schema }
      let(:record) { record_class.new }
      let(:record_class) do
        Class.new do
          def dynamic_schema
            'foo'
          end
        end
      end

      it { expect(schema).to eql('foo') }
    end
  end

  describe :validatable_value do
    let(:validator) { JsonValidator.new(options) }
    let(:options) { { attributes: [:foo] } }
    let(:validatable_value) { validator.send(:validatable_value, value) }

    context 'with non-String value' do
      let(:value) { { foo: 'bar' } }
      it { expect(validatable_value).to eql('{"foo":"bar"}') }
    end

    context 'with String value' do
      let(:value) { '{\"foo\":\"bar\"}' }
      it { expect(validatable_value).to eql(value) }
    end
  end

  describe :message do
    let(:validator) { JsonValidator.new(options) }
    let(:options) { { attributes: [:foo], message: message_option } }
    let(:message) { validator.send(:message, errors) }
    let(:errors) { %i[first_error second_error] }

    context 'with Symbol message' do
      let(:message_option) { :invalid_json }
      it { expect(message).to eql([:invalid_json]) }
    end

    context 'with String value' do
      let(:message_option) { ->(errors) { errors } }
      it { expect(message).to eql(%i[first_error second_error]) }
    end
  end
end
# rubocop:enable Metrics/BlockLength
