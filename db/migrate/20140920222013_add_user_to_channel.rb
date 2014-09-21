class AddUserToChannel < ActiveRecord::Migration
  def change
    add_reference :channels, :user
  end
end
