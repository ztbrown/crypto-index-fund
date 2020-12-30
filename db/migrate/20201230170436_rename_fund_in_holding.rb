class RenameFundInHolding < ActiveRecord::Migration[6.0]
  def change
    rename_column :holdings, :fund_id, :snapshot_id
  end
end
