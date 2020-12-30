class RenameFundTableToSnapshot < ActiveRecord::Migration[6.0]
  def change
    rename_table :funds, :snapshots
  end
end
