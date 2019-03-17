class CreateCoordinates < ActiveRecord::Migration[5.1]
  def change
    create_table :coordinates do |t|
      t.decimal :latitude
      t.decimal :longitude
      t.belongs_to :place, index: true
    end
  end
end
