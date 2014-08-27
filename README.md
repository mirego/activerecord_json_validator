# ActiveRecord::JSONValidator

`ActiveRecord::JSONValidator` makes it easy to validate JSON attributes against a JSON schema.

<a href="https://rubygems.org/gems/activerecord_json_validator"><img src="https://badge.fury.io/rb/activerecord_json_validator.png" /></a>
<a href="https://travis-ci.org/mirego/activerecord_json_validator"><img src="https://travis-ci.org/mirego/activerecord_json_validator.png?branch=master" /></a>
<a href='https://coveralls.io/r/mirego/activerecord_json_validator?branch=master'><img src='https://coveralls.io/repos/mirego/activerecord_json_validator/badge.png?branch=master' alt='Coverage Status' /></a>

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
  PROFILE_JSON_SCHEMA = Rails.root.join('config', 'schemas', 'profile.json_schema')

  # Validations
  validates :name, presence: true
  validates :profile, presence: true, json: { schema: File.read(PROFILE_JSON_SCHEMA) }
end

user = User.new(name: 'Samuel Garneau', profile: { city: 'Quebec City' })
user.valid? # => false

user = User.new(name: 'Samuel Garneau', profile: { city: 'Quebec City', country: 'Canada' })
user.valid? # => true
```

## License

`ActiveRecord::JSONValidator` is © 2013 [Mirego](http://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).  See the [`LICENSE.md`](https://github.com/mirego/activerecord_json_validator/blob/master/LICENSE.md) file.

## About Mirego

[Mirego](http://mirego.com) is a team of passionate people who believe that work is a place where you can innovate and have fun. We're a team of [talented people](http://life.mirego.com) who imagine and build beautiful Web and mobile applications. We come together to share ideas and [change the world](http://mirego.org).

We also [love open-source software](http://open.mirego.com) and we try to give back to the community as much as we can.
