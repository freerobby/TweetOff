class RaceUpdater
  def self.update!(race_id)
    Race.find(race_id).go!
  end
  
  def self.update_all!
    Race.all.each do |race|
      self.update!(race.id) unless race.complete?
    end
  end
end