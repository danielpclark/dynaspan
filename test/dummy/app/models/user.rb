# frozen_string_literal: true

class User < ApplicationRecord
  ROLES = [%w[Administrator admin], %w[Editor editor], %w[Viewer viewer]].freeze

  has_many :websites, dependent: :destroy
  accepts_nested_attributes_for :websites

  validates :name, presence: true
end
