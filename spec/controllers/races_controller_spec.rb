require 'spec_helper'

describe RacesController do

  def mock_race(stubs={})
    @mock_race ||= mock_model(Race, stubs)
  end

  describe "GET index" do
    it "assigns all races as @races" do
      Race.stub!(:find).with(:all).and_return([mock_race])
      get :index
      assigns[:races].should == [mock_race]
    end
  end

  describe "GET show" do
    it "assigns the requested race as @race" do
      Race.stub!(:find).with("37").and_return(mock_race)
      get :show, :id => "37"
      assigns[:race].should equal(mock_race)
    end
  end

  describe "GET new" do
    it "assigns a new race as @race" do
      FakeWeb.register_uri(:get, "http://search.twitter.com/trends/current.json", :body => FakeTrendsJSON) # Don't make call for Twitter trends
      Race.stub!(:new).and_return(mock_race)
      get :new
      assigns[:race].should equal(mock_race)
    end
  end

  describe "GET edit" do
    it "assigns the requested race as @race" do
      Race.stub!(:find).with("37").and_return(mock_race)
      get :edit, :id => "37"
      assigns[:race].should equal(mock_race)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created race as @race" do
        Race.stub!(:new).with({'these' => 'params'}).and_return(mock_race(:save => true))
        post :create, :race => {:these => 'params'}
        assigns[:race].should equal(mock_race)
      end

      it "redirects to the created race" do
        Race.stub!(:new).and_return(mock_race(:save => true))
        post :create, :race => {}
        response.should redirect_to(race_url(mock_race))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved race as @race" do
        Race.stub!(:new).with({'these' => 'params'}).and_return(mock_race(:save => false))
        post :create, :race => {:these => 'params'}
        assigns[:race].should equal(mock_race)
      end

      it "re-renders the 'new' template" do
        Race.stub!(:new).and_return(mock_race(:save => false))
        post :create, :race => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do
    it "does not find the update action" do
      lambda {put :update, :id => "37", :race => {:these => 'params'}}.should raise_error(ActionController::UnknownAction)
    end
  end

  describe "DELETE destroy" do
    it "does not find the destroy action" do
      lambda {delete :destroy, :id => "37"}.should raise_error(ActionController::UnknownAction)
    end
  end

end
