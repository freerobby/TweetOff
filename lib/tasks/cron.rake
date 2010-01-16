task :cron => :environment do
  puts "Updating all incomplete TweetOffs..."
  RaceUpdater::update_all!
  puts "Update complete"
end