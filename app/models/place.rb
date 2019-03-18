class Place < ApplicationRecord
    has_many :opening_hours
    has_one :coordinates, class_name: 'Coordinate'

    scope :by_matching_name, ->(name) { where("levenshtein(name, ?) < 3", name) }
end
