class AddToCoins < ActiveRecord::Migration[6.0]
  def change
    add_column :coins, :cmc_id, :integer
    add_column :coins, :slug, :string
  end
end
