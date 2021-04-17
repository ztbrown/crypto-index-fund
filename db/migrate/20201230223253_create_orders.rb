class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.belongs_to :coin
      t.string :side
      t.string :pair
      t.decimal :amount
      t.boolean :completed, default: false
      t.string :order_id

      t.timestamps
    end
  end
end
