class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.string :price_currency
      t.decimal :price_amount
      t.string :weight_magnitude
      t.decimal :weight_quantity

      t.timestamps
    end
  end
end
