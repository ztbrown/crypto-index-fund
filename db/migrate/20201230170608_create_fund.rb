class CreateFund < ActiveRecord::Migration[6.0]
  def change
    create_table :funds do |t|
      t.string :name
      t.text :description
      t.timestamps
    end
    add_reference :snapshots, :fund, foreign_key: true
  end
end
