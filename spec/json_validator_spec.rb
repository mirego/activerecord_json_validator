require 'spec_helper'

describe JsonValidator do
  before do
    run_migration do
      create_table(:users, force: true) do |t|
        t.string :name
        t.text :profile
      end
    end

    spawn_model :User do
      schema = {
        type: 'object',
        :'$schema' => 'http://json-schema.org/draft-03/schema',
        properties: {
          city: { type: 'string', required: false },
          country: { type: 'string', required: true }
        }
      }

      serialize :profile, JSON
      validates :name, presence: true
      validates :profile, presence: true, json: { schema: schema }
    end
  end

  let(:user) { User.create(attributes) }

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
end
