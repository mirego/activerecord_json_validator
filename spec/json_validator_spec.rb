# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
require 'spec_helper'

describe JsonValidator do
  describe :validate_each do
    before do
      run_migration do
        create_table(:users, force: true) do |t|
          t.text :data
          t.json :smart_data
        end
      end

      spawn_model 'User' do
        schema = '
        {
          "type": "object",
          "properties": {
            "city": { "type": "string" },
            "country": { "type": "string" }
          },
          "required": ["country"]
        }
        '
        serialize :data, JSON
        serialize :other_data, JSON
        validates :data, json: { schema: schema, message: ->(errors) { errors } }
        validates :other_data, json: { schema: schema, message: ->(errors) { errors.map { |error| error['details'].to_a.flatten.join(' ') } } }
        validates :smart_data, json: { schema: schema, message: ->(errors) { errors } }

        def smart_data
          OpenStruct.new(self[:smart_data])
        end
      end
    end

    context 'with valid JSON data but schema errors' do
      let(:user) { User.new(data: '{"city":"Quebec City"}', other_data: '{"city":"Quebec City"}', smart_data: {country: "Canada", city: "Quebec City"}) }

      specify do
        expect(user).not_to be_valid
        expect(user.errors.full_messages).to eql(['Data root is missing required keys: country', 'Other data missing_keys country'])
        expect(user.data).to eql({ 'city' => 'Quebec City' })
        expect(user.data_invalid_json).to be_nil
      end
    end

    context 'with invalid JSON data' do
      let(:data) { 'What? This is not JSON at all.' }
      let(:user) { User.new(data: data) }

      specify do
        expect(user.data_invalid_json).to eql(data)
        expect(user.data).to eql({})
      end
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
