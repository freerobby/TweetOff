class RaceUpdater
  def self.update!(race_id)
    r = Race.find(race_id)
    r.go! unless r.complete?
  end
  
  def self.update_all!
    Race.complete_equals(false).each do |race|
      self.update!(race.id)
    end
  end
end