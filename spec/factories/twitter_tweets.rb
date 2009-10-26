Factory.define :tt1, :class => :twitter_tweet do |t|
  t.add_attribute :twitter_id, 90000000000
  t.add_attribute :text, "I just signed up for twitter!"
  t.add_attribute :author, "papelbuns"
  t.add_attribute :tweeted_at, 1.second.from_now
  t.add_attribute :term, 1
  t.race {|r| r.association(:twitter_vs_facebook)}
end

Factory.define :tt2, :class => :twitter_tweet do |t|
  t.add_attribute :twitter_id, 90000000001
  t.add_attribute :text, "I just signed up for Facebook!"
  t.add_attribute :author, "freerobby"
  t.add_attribute :tweeted_at, 1.second.from_now
  t.add_attribute :term, 2
  t.race {|r| r.association(:twitter_vs_facebook)}
end

Factory.define :tt3, :class => :twitter_tweet do |t|
  t.add_attribute :twitter_id, 90000000005
  t.add_attribute :text, "I just signed up for Facebook and Twitter!"
  t.add_attribute :author, "papelbuns"
  t.add_attribute :tweeted_at, 5.seconds.from_now
  t.add_attribute :term, 1
  t.race {|r| r.association(:twitter_vs_facebook)}
end

Factory.define :tt4, :class => :twitter_tweet do |t|
  t.add_attribute :twitter_id, 90000000005
  t.add_attribute :text, "I just signed up for Facebook and Twitter!"
  t.add_attribute :author, "papelbuns"
  t.add_attribute :tweeted_at, 5.seconds.from_now
  t.add_attribute :term, 2
  t.race {|r| r.association(:twitter_vs_facebook)}
end

Factory.define :tt5, :class => :twitter_tweet do |t|
  t.add_attribute :twitter_id, 90000000009
  t.add_attribute :text, "I hate Facebook!"
  t.add_attribute :author, "ev"
  t.add_attribute :tweeted_at, 12.seconds.from_now
  t.add_attribute :term, 2
  t.race {|r| r.association(:twitter_vs_facebook)}
end

Factory.define :tt6, :class => :twitter_tweet do |t|
  t.add_attribute :twitter_id, 90000000010
  t.add_attribute :text, "I love Twitter!"
  t.add_attribute :author, "jason"
  t.add_attribute :tweeted_at, 14.seconds.from_now
  t.add_attribute :term, 1
  t.race {|r| r.association(:twitter_vs_facebook)}
end

Factory.define :tt7, :class => :twitter_tweet do |t|
  t.add_attribute :twitter_id, 90000000015
  t.add_attribute :text, "Twitter Rocks!"
  t.add_attribute :author, "freerobby"
  t.add_attribute :tweeted_at, 15.seconds.from_now
  t.add_attribute :term, 1
  t.race {|r| r.association(:twitter_vs_facebook)}
end

Factory.define :tt8, :class => :twitter_tweet do |t|
  t.add_attribute :twitter_id, 90000000020
  t.add_attribute :text, "Facebook is meh."
  t.add_attribute :author, "freerobby"
  t.add_attribute :tweeted_at, 20.seconds.from_now
  t.add_attribute :term, 2
  t.race {|r| r.association(:twitter_vs_facebook)}
end