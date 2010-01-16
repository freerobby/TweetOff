class AddCompleteToRaces < ActiveRecord::Migration
  def self.up
    add_column :races, :complete, :boolean, :default => false
    
    Race.all.each do |race|
      if race.is_complete?
        race.update_attribute(:complete, true)
      else
        race.update_attribute(:complete, false)
      end
    end
  end

  def self.down
    remove_column :races, :complete
  end
end
