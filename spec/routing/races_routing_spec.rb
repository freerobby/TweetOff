require 'spec_helper'

describe RacesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/races" }.should route_to(:controller => "races", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/races/new" }.should route_to(:controller => "races", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/races/1" }.should route_to(:controller => "races", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/races/1/edit" }.should route_to(:controller => "races", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/races" }.should route_to(:controller => "races", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/races/1" }.should route_to(:controller => "races", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/races/1" }.should route_to(:controller => "races", :action => "destroy", :id => "1") 
    end
  end
end
