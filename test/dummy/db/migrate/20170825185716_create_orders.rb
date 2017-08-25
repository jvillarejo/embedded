class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.string :price_currency
      t.decimal :price_amount

      t.timestamps
    end
  end
end
