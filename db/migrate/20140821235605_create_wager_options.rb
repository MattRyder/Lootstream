class CreateWagerOptions < ActiveRecord::Migration
  def change
    create_table :wager_options do |t|
      t.string :text
      t.belongs_to :wager, index: true

      t.timestamps
    end
  end
end
