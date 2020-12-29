class AddQuotes < ActiveRecord::Migration[6.0]
  def change
    create_table :quotes do |t|
      t.datetime :timestamp
      t.float :price
      t.float :volume_24h
      t.float :market_cap
      t.belongs_to :coin

      t.timestamps
    end
  end
end
