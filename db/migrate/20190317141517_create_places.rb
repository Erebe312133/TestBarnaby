class CreatePlaces < ActiveRecord::Migration[5.1]
  def change
    create_table :places do |t|
      t.string :name
      t.boolean :has_offers
      t.boolean :is_payment_available
      t.boolean :is_booking_available
      t.boolean :is_favorited
      t.string :picture_url
    end
  end
end
