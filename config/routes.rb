ActionController::Routing::Routes.draw do |map|
  map.resources :races, :only => [:index, :show, :new, :create], :collection => {
    :latest_tweets => :get,
    :update_query_status => :get,
    :update_race_status => :get,
    :refresh_status => :post
  }
  map.resources :pages, :controller => "pages", :only => [:show]
  
  map.root :controller => :pages, :id => :about, :action => :show
end
