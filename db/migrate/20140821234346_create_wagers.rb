class CreateWagers < ActiveRecord::Migration
  def change
    create_table :wagers do |t|
      t.string :question
      t.decimal :min_amount
      t.decimal :max_amount
      t.boolean :active, default: true
      t.datetime :suspended_at
      t.belongs_to :game, index: true
      t.belongs_to :channel, index: true

      t.timestamps
    end
  end
end
