class Place < ApplicationRecord
    has_many :opening_hours
    has_one :coordinates, class_name: 'Coordinate'
end
