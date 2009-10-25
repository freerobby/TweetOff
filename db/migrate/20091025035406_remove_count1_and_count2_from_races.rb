class RemoveCount1AndCount2FromRaces < ActiveRecord::Migration
  def self.up
    remove_column :races, :count1
    remove_column :races, :count2
  end

  def self.down
    puts "Sorry, forward only!"
  end
end
