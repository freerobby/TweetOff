class RacesController < ApplicationController
  # GET /races
  # GET /races.xml
  def index
    @search = Race.search(params[:search])
    @races = @search.all.paginate(:page => params[:page], :per_page => 25)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @races }
    end
  end

  # GET /races/1
  # GET /races/1.xml
  def show
    @race = Race.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @race }
    end
  end
  def latest_tweets
    @race = Race.find(params[:id])
    last_tweet = @race.twitter_tweets.descend_by_twitter_id.first
    last_twitter_id = 0
    last_twitter_id = last_tweet.twitter_id if !last_tweet.nil?
    render :partial => "latest_tweets", :locals => {:last_twitter_id => last_twitter_id, :tweets => TwitterTweet.race_id_equals(@race.id).term_equals(params[:term]).twitter_id_greater_than(params[:last_twitter_id].to_i).ascend_by_twitter_id}
  end
  def refresh_status
    @race = Race.find(params[:id])
    @race.go!
    render :text => "Success!"
  end
  
  def update_query_status
    if request.xhr?
      @race = Race.find(params[:id])
      render :partial => "query_status", :locals => {:race => @race, :term => params[:term]}
    else
      redirect_to '/'
    end
  end
  
  def update_race_status
    if request.xhr?
      @race = Race.find(params[:id])
      render :partial => "race_status"
    else
      redirect_to '/'
    end
  end

  # GET /races/new
  # GET /races/new.xml
  def new
    @race = Race.new
    # client = TwitterSearch::Client.new('TweetOff!')
    # @trends = client.trends
    @trends = TwitterTrends::current

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @race }
    end
  end

  # POST /races
  # POST /races.xml
  def create
    @race = Race.new(params[:race])

    respond_to do |format|
      if @race.save
        #flash[:notice] = 'Race was successfully created.'
        format.html { redirect_to(@race) }
        format.xml  { render :xml => @race, :status => :created, :location => @race }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @race.errors, :status => :unprocessable_entity }
      end
    end
  end
end
