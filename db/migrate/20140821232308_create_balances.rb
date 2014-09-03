class CreateBalances < ActiveRecord::Migration
  def change
    create_table :balances do |t|
      t.belongs_to :user, index: true
      t.belongs_to :stream, index: true
      t.decimal :balance, precision: 8, scale: 2

      t.timestamps
    end
  end
end
