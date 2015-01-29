require 'spec_helper'

describe JsonValidator do
  before do
    run_migration do
      create_table(:users, force: true) do |t|
        t.string :name
        t.text :profile
      end
    end

    json_schema = schema
    spawn_model :User do
      serialize :profile, JSON
      validates :name, presence: true
      validates :profile, presence: true, json: { schema: json_schema }

      def dynamic_json_schema
        {
          type: 'object',
          :'$schema' => 'http://json-schema.org/draft-03/schema',
          properties: {
            foo: { type: 'string', required: false },
            bar: { type: 'string', required: true }
          }
        }
      end
    end
  end

  let(:user) { User.create(attributes) }
  let(:schema) do
    {
      type: 'object',
      :'$schema' => 'http://json-schema.org/draft-03/schema',
      properties: {
        city: { type: 'string', required: false },
        country: { type: 'string', required: true }
      }
    }
  end

  context 'with blank JSON value' do
    let(:attributes) { { name: 'Samuel Garneau', profile: {} } }
    it { expect(user).to_not be_valid }
  end

  context 'with invalid JSON value' do
    context 'as Ruby Hash' do
      let(:attributes) { { name: 'Samuel Garneau', profile: { city: 'Quebec City' } } }
      it { expect(user).to_not be_valid }
    end

    context 'as JSON string' do
      let(:attributes) { { name: 'Samuel Garneau', profile: '{ "city": "Quebec City" }' } }
      it { expect(user).to_not be_valid }
    end
  end

  context 'with valid JSON value' do
    context 'as Ruby Hash' do
      let(:attributes) { { name: 'Samuel Garneau', profile: { country: 'CA' } } }
      it { expect(user).to be_valid }
    end

    context 'as JSON string' do
      let(:attributes) { { name: 'Samuel Garneau', profile: '{ "country": "CA" }' } }
      it { expect(user).to be_valid }
    end
  end

  context 'with malformed JSON string' do
    let(:attributes) { { name: 'Samuel Garneau', profile: 'foo:}bar' } }

    specify do
      expect(user).to_not be_valid
      expect(user.profile).to eql({})
      expect(user.profile_invalid_json).to eql('foo:}bar')
    end
  end

  context 'with lambda schema option' do
    # The dynamic schema makes `country` and `city` keys mandatory
    let(:schema) { lambda { dynamic_json_schema } }

    context 'with valid JSON value' do
      let(:attributes) { { name: 'Samuel Garneau', profile: { foo: 'bar', bar: 'foo' } } }
      it { expect(user).to be_valid }
    end

    context 'with invalid JSON value' do
      let(:attributes) { { name: 'Samuel Garneau', profile: {} } }
      it { expect(user).not_to be_valid }
    end
  end

  context 'with JSON inflection' do
    it { expect(JSONValidator).to equal(JsonValidator) }
  end
end
