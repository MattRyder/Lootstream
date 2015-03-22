class AddAPIKeyToUser < ActiveRecord::Migration
  def change
    add_column :users, :api_key, :string
    add_column :users, :api_key_created_at, :datetime
  end
end
