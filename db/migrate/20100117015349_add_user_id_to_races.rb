class AddUserIdToRaces < ActiveRecord::Migration
  def self.up
    add_column :races, :user_id, :integer
  end

  def self.down
    remove_column :races, :user_id
  end
end
