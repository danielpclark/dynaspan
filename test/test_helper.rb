# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require_relative 'dummy/config/environment'
require 'rails/test_help'

module DynaspanTestData
  def create_user(**attributes)
    User.create!({ name: 'Ada Lovelace', title: 'Analyst', role: 'admin', bio: 'First programmer.' }.merge(attributes))
  end
end

ActiveSupport::TestCase.include(DynaspanTestData)
