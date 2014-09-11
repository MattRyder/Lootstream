class AddWonToWager < ActiveRecord::Migration
  def change
    add_column :wagers, :winning_option, :integer
  end
end
