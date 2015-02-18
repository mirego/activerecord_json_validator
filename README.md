<p align="center">
  <a href="https://github.com/mirego/activerecord_json_validator">
    <img src="https://cloud.githubusercontent.com/assets/11348/6099354/cffcf35e-afc3-11e4-9a4d-d872941bbcf6.png" alt="" />
  </a>
  <br />
  <code>ActiveRecord::JSONValidator</code> makes it easy to validate<br /> JSON attributes against a <a href="http://json-schema.org/">JSON schema</a>.
  <br /><br />
  <a href="https://rubygems.org/gems/activerecord_json_validator"><img src="http://img.shields.io/gem/v/activerecord_json_validator.svg" /></a>
  <a href="https://travis-ci.org/mirego/activerecord_json_validator"><img src="http://img.shields.io/travis/mirego/activerecord_json_validator.svg" /></a>
</p>

---

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
  "$schema": "http://json-schema.org/draft-04/schema",
  "properties": {
    "city": { "type": "string" },
    "country": { "type": "string" }
  },
  "required": ["country"]
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

#### Options

| Option     | Description
|------------|-----------------------------------------------------
| `:schema`  | The JSON schema to validate the data against (see **JSON schema option** section)
| `:message` | The ActiveRecord message added to the record errors (see **Message option**)

##### Message option

Like any other ActiveModel validation, you can specify either a `Symbol` or
`String` value for the `:message` option. The default value is `:invalid_json`.

However, you can also specify a `Proc` that returns an array of errors. The
`Proc` will be called with a single argument — an array of errors returned by
the JSON schema validator. So, if you’d like to add each of these errors as
a first-level error for the record, you can do this:

```ruby
class User < ActiveRecord::Base
  # Validations
  validates :profile, presence: true, json: { message: ->(errors) { errors }, schema: 'foo.json_schema' }
end

user = User.new.tap(&:valid?)
user.errors.full_messages
# => [
#      'The property '#/email' of type Fixnum did not match the following type: string in schema 2d44293f-cd9d-5dca-8a6a-fb9db1de722b#',
#      'The property '#/full_name' of type Fixnum did not match the following type: string in schema 2d44293f-cd9d-5dca-8a6a-fb9db1de722b#',
#    ]
```

##### JSON schema option

You can specify four kinds of value for the `:schema` option.

###### A path to a file containing a JSON schema

```ruby
class User < ActiveRecord::Base
  # Constants
  PROFILE_JSON_SCHEMA = Rails.root.join('config', 'schemas', 'profile.json_schema').to_s

  # Validations
  validates :profile, presence: true, json: { schema: PROFILE_JSON_SCHEMA }
end
```

###### A Ruby `Hash` representing a JSON schema

```ruby
class User < ActiveRecord::Base
  # Constants
  PROFILE_JSON_SCHEMA = {
    type: 'object',
    :'$schema' => 'http://json-schema.org/draft-04/schema',
    properties: {
      city: { type: 'string' },
      country: { type: 'string' }
    },
    required: ['country']
  }

  # Validations
  validates :profile, presence: true, json: { schema: PROFILE_JSON_SCHEMA }
end
```

###### A plain JSON schema as a Ruby `String`

```ruby
class User < ActiveRecord::Base
  # Constants
  PROFILE_JSON_SCHEMA = '{
    "type": "object",
    "$schema": "http://json-schema.org/draft-04/schema",
    "properties": {
      "city": { "type": "string" },
      "country": { "type": "string" }
    },
    "required": ["country"]
  }'

  # Validations
  validates :profile, presence: true, json: { schema: PROFILE_JSON_SCHEMA }
end
```

###### A lambda that will get evaluated in the context of the validated record

The lambda must return a valid value for the `:schema` option (file path, JSON `String` or Ruby `Hash`).

```ruby
class User < ActiveRecord::Base
  # Constants
  PROFILE_REGULAR_JSON_SCHEMA = Rails.root.join('config', 'schemas', 'profile.json_schema').to_s
  PROFILE_ADMIN_JSON_SCHEMA = Rails.root.join('config', 'schemas', 'profile_admin.json_schema').to_s

  # Validations
  validates :profile, presence: true, json: { schema: lambda { dynamic_profile_schema } }

  def dynamic_profile_schema
    admin? ? PROFILE_ADMIN_JSON_SCHEMA : PROFILE_REGULAR_JSON_SCHEMA
  end
end
```

## License

`ActiveRecord::JSONValidator` is © 2013-2015 [Mirego](http://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).  See the [`LICENSE.md`](https://github.com/mirego/activerecord_json_validator/blob/master/LICENSE.md) file.

The tree logo is based on [this lovely icon](http://thenounproject.com/term/tree/51004/) by [Sara Quintana](http://thenounproject.com/sara.quintana.75), from The Noun Project. Used under a [Creative Commons BY 3.0](http://creativecommons.org/licenses/by/3.0/) license.

## About Mirego

[Mirego](http://mirego.com) is a team of passionate people who believe that work is a place where you can innovate and have fun. We're a team of [talented people](http://life.mirego.com) who imagine and build beautiful Web and mobile applications. We come together to share ideas and [change the world](http://mirego.org).

We also [love open-source software](http://open.mirego.com) and we try to give back to the community as much as we can.
