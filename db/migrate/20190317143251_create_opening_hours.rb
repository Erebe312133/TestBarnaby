class CreateOpeningHours < ActiveRecord::Migration[5.1]
  def change
    create_table :opening_hours do |t|
      t.string :week_day
      t.integer :open_time
      t.integer :close_time
      t.belongs_to :place, index: true
    end
  end
end
