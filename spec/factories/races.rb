Factory.define :twitter_vs_facebook, :class => :race do |r|
  r.add_attribute :term1, "Twitter"
  r.add_attribute :term2, "Facebook"
  r.add_attribute :race_to, 10
end