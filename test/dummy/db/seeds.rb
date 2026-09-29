# frozen_string_literal: true

user = User.create!(
  name: 'Ada Lovelace',
  title: 'Analyst & Metaphysician',
  role: 'admin',
  bio: 'Wrote the first published algorithm intended for a machine.'
)
user.websites.create!(url: 'https://example.com/ada')
