class AddTagsAndTaggableToCoins < ActiveRecord::Migration[6.0]
  def change
    create_table :tags do |t|
      t.string :name

      t.timestamps
    end

    create_table :taggable do |t|
      t.belongs_to :coin
      t.belongs_to :tag

      t.timestamps
    end
  end
end
