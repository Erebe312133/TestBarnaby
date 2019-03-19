class Coordinate < ApplicationRecord
    belongs_to :place
    acts_as_mappable    lat_column_name: :latitude,
                        lng_column_name: :longitude
end
