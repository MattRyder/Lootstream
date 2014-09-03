class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.decimal :amount
      t.belongs_to :user, index: true
      t.belongs_to :wager_option, index: true

      t.timestamps
    end
  end
end
