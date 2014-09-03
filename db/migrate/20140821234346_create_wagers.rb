class CreateWagers < ActiveRecord::Migration
  def change
    create_table :wagers do |t|
      t.string :question
      t.decimal :min_amount
      t.decimal :max_amount
      t.boolean :active
      t.datetime :suspended_at
      t.belongs_to :game, index: true
      t.belongs_to :stream, index: true

      t.timestamps
    end
  end
end
