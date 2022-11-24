<p align="center">
  <a href="https://github.com/mirego/activerecord_json_validator">
    <img src="https://user-images.githubusercontent.com/11348/126779905-3468eb15-d554-46d5-925b-235f68169d86.png" alt="" />
  </a>
  <br />
  <code>ActiveRecord::JSONValidator</code> makes it easy to validate<br /> JSON attributes against a <a href="https://json-schema.org/">JSON schema</a>.
  <br /><br />
  <a href="https://rubygems.org/gems/activerecord_json_validator"><img src="https://img.shields.io/gem/v/activerecord_json_validator.svg" /></a>
  <a href="https://github.com/mirego/activerecord_json_validator/actions/workflows/ci.yaml"><img src="https://github.com/mirego/activerecord_json_validator/actions/workflows/ci.yaml/badge.svg" /></a>
</p>

---

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord_json_validator', '~> 2.0.0'
```

## Usage

### JSON Schema

Schemas should be a JSON file

```json
{
  "type": "object",
  "$schema": "http://json-schema.org/draft-04/schema#",
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
  PROFILE_JSON_SCHEMA = Rails.root.join('config', 'schemas', 'profile.json')

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

| Option     | Description                                                                                                                    |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `:schema`  | The JSON schema to validate the data against (see **Schema** section)                                                          |
| `:value`   | The actual value to use when validating (see **Value** section)                                                                |
| `:message` | The ActiveRecord message added to the record errors (see **Message** section)                                                  |
| `:options` | A `Hash` of [`json_schemer`](https://github.com/davishmcclurg/json_schemer#options)-supported options to pass to the validator |

##### Schema

`ActiveRecord::JSONValidator` uses the [json_schemer](https://github.com/davishmcclurg/json_schemer) gem to validate the JSON
data against a JSON schema.

Additionally, you can use a `Symbol` or a `Proc`. Both will be executed in the
context of the validated record (`Symbol` will be sent as a method and the
`Proc` will be `instance_exec`ed)

```ruby
class User < ActiveRecord::Base
  # Constants
  PROFILE_REGULAR_JSON_SCHEMA = Rails.root.join('config', 'schemas', 'profile.json_schema')
  PROFILE_ADMIN_JSON_SCHEMA = Rails.root.join('config', 'schemas', 'profile_admin.json_schema')

  # Validations
  validates :profile, presence: true, json: { schema: lambda { dynamic_profile_schema } } # `schema: :dynamic_profile_schema` would also work

  def dynamic_profile_schema
    admin? ? PROFILE_ADMIN_JSON_SCHEMA : PROFILE_REGULAR_JSON_SCHEMA
  end
end
```

The schema is passed to the `JSONSchemer.schema` function, so it can be anything supported by it:

```ruby
class User < ActiveRecord::Base
  # Constants
  JSON_SCHEMA = Rails.root.join('config', 'schemas', 'profile.json_schema')
  # JSON_SCHEMA = { 'type' => 'object', 'properties' => { 'foo' => { 'type' => 'integer', 'minimum' => 3 } } }
  # JSON_SCHEMA = '{"type":"object","properties":{"foo":{"type":"integer","minimum":3}}}'

  # Validations
  validates :profile, presence: true, json: { schema: JSON_SCHEMA }
end
```

##### Value

By default, the validator will use the “getter” method to the fetch attribute
value and validate the schema against it.

```ruby
# Will validate `self.foo`
validates :foo, json: { schema: SCHEMA }
```

But you can change this behavior if the getter method doesn’t return raw JSON data (a `Hash`):

```ruby
# Will validate `self[:foo]`
validates :foo, json: { schema: SCHEMA, value: ->(record, _, _) { record[:foo] } }
```

You could also implement a “raw getter” if you want to avoid the `value` option:

```ruby
# Will validate `self[:foo]`
validates :raw_foo, json: { schema: SCHEMA }

def raw_foo
  self[:foo]
end
```

##### Message

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

## License

`ActiveRecord::JSONValidator` is © 2013-2022 [Mirego](https://www.mirego.com) and may be freely distributed under the [New BSD license](https://opensource.org/licenses/BSD-3-Clause). See the [`LICENSE.md`](https://github.com/mirego/activerecord_json_validator/blob/master/LICENSE.md) file.

The tree logo is based on [this lovely icon](https://thenounproject.com/term/tree/51004/) by [Sara Quintana](https://thenounproject.com/sara.quintana.75), from The Noun Project. Used under a [Creative Commons BY 3.0](https://creativecommons.org/licenses/by/3.0/) license.

## About Mirego

[Mirego](https://www.mirego.com) is a team of passionate people who believe that work is a place where you can innovate and have fun. We're a team of [talented people](https://life.mirego.com) who imagine and build beautiful Web and mobile applications. We come together to share ideas and [change the world](https://www.mirego.org).

We also [love open-source software](https://open.mirego.com) and we try to give back to the community as much as we can.
