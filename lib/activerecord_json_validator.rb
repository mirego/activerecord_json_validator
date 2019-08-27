# frozen_string_literal: true

require 'active_record'
require 'json-schema'

require 'active_record/json_validator/version'
require 'active_record/json_validator/validator'

# NOTE: In case `"JSON"` is treated as an acronym by `ActiveSupport::Inflector`,
# make `JSONValidator` available too.
JSONValidator = JsonValidator
