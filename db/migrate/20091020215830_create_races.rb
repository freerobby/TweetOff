class CreateRaces < ActiveRecord::Migration
  def self.up
    create_table :races do |t|
      t.string :term1
      t.string :term2
      t.integer :count1, :allow_nil => false, :default => 0
      t.integer :count2, :allow_nil => false, :default => 0
      t.integer :race_to, :allow_nil => false, :default => 100

      t.timestamps
    end
  end

  def self.down
    drop_table :races
  end
end
