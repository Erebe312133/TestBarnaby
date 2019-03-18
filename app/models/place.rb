class Place < ApplicationRecord
    has_many :opening_hours
    has_one :coordinates, class_name: 'Coordinate'

    scope :by_matching_name, ->(name) { where("lower(name) LIKE ?", "%#{name.downcase}%") }
end
