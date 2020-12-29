class AddHoldings < ActiveRecord::Migration[6.0]
  def change
    create_table :funds do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
    create_table :holdings do |t|
      t.belongs_to :fund 
      t.belongs_to :coin

      t.float :amount

      t.timestamps
    end
  end
end
