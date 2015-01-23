# ActiveRecord::JSONValidator

`ActiveRecord::JSONValidator` makes it easy to validate JSON attributes against a JSON schema.

[![Gem Version](http://img.shields.io/gem/v/activerecord_json_validator.svg)](https://rubygems.org/gems/activerecord_json_validator)
[![Build Status](http://img.shields.io/travis/mirego/activerecord_json_validator.svg)](https://travis-ci.org/mirego/activerecord_json_validator)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord_json_validator'
```

## Usage

### JSON Schema

```json
{
  "type": "object",
  "$schema": "http://json-schema.org/draft-03/schema",
  "properties": {
    "city": { "type": "string", "required": false },
    "country": { "type": "string", "required": true }
  }
}
```

### Ruby

```ruby
create_table "users" do |t|
  t.string "name"
  t.json "profile" # First-class JSON with PostgreSQL, yo.
end

class User < ActiveRecord::Base
  # Constants
  PROFILE_JSON_SCHEMA = Rails.root.join('config', 'schemas', 'profile.json_schema').to_s

  # Validations
  validates :name, presence: true
  validates :profile, presence: true, json: { schema: PROFILE_JSON_SCHEMA }
end

user = User.new(name: 'Samuel Garneau', profile: { city: 'Quebec City' })
user.valid? # => false

user = User.new(name: 'Samuel Garneau', profile: { city: 'Quebec City', country: 'Canada' })
user.valid? # => true

user = User.new(name: 'Samuel Garneau', profile: '{invalid JSON":}')
user.valid? # => false
user.profile_invalid_json # => '{invalid JSON":}'
```

## Dynamic Schemas

Is possible to have a dynamic schemas defining an instance method in the model class.

To configure the schema method name used to load the dynamic schema (ex: /config/initializers/activerecord_json_validator.rb):

```ruby
JsonValidator.schema_method = :_json_schema # default
```

In model:

```ruby
class User extends ActiveRecord::Base
  # User table has a role_id field
protected
  def _json_schema
    # Must return a schema path or hash as json object
    case role_id
    when 1
      Rails.root.join('config', 'schemas', 'users', 'admin.json_schema').to_s
    else
      Rails.root.join('config', 'schemas', 'users', 'default.json_schema').to_s
  end
```

## License

`ActiveRecord::JSONValidator` is © 2013-2015 [Mirego](http://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).  See the [`LICENSE.md`](https://github.com/mirego/activerecord_json_validator/blob/master/LICENSE.md) file.

## About Mirego

[Mirego](http://mirego.com) is a team of passionate people who believe that work is a place where you can innovate and have fun. We're a team of [talented people](http://life.mirego.com) who imagine and build beautiful Web and mobile applications. We come together to share ideas and [change the world](http://mirego.org).

We also [love open-source software](http://open.mirego.com) and we try to give back to the community as much as we can.
