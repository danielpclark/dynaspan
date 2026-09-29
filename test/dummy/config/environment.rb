# frozen_string_literal: true

require_relative 'application'

Rails.application.initialize!

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name
    t.string :title
    t.string :role
    t.text :bio
  end

  create_table :websites, force: true do |t|
    t.references :user
    t.string :url
  end
end
