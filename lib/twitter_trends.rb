require 'net/http'
require 'json'
 
class TwitterTrends
 
  def self.current
    res = http_get("current")
    res["trends"].values.first.map {|trend| trend["name"]}
  end
 
  def self.daily(date)
    date = Date.parse(date)
    res = http_get("daily", date.to_s)
    day = {}
    res["trends"].each_pair do |date, trend|
      day.store(date.split[1], trend.map {|trend| trend["name"]})
    end
    day
  end
 
  def self.weekly(date)
    res = http_get("weekly", date)
    week = {}
    res["trends"].each_pair do |date, trend|
      week.store(date, trend.map {|trend| trend["name"]})
    end
    week
  end
 
  private
  def self.http_get(resource, date = nil)
    url = URI.parse("http://search.twitter.com")
    resp = Net::HTTP.start(url.host, url.port) {|http|
      http.get("/trends/#{resource}.json")
    }
    JSON.parse(resp.body)
  end
end