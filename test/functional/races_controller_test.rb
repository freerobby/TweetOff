require 'test_helper'

class RacesControllerTest < ActionController::TestCase
  context "on GET to :index" do
    setup do
      get :index
    end
    should_respond_with :success
    should_render_template :index
  end
  context "on GET to :new" do
    setup do
      get :new
    end
    should_respond_with :success
    should_render_template :new
  end
  context "on POST to :create" do
    setup do
      post :create, :race => Factory.attributes_for(:race)
    end
    # should_redirect_to "/races/#{Race.last.id}/show"
    should_respond_with :redirect
    should "find the last tweet" do
      assert Race.last.last_tweet1.to_i > 0
      assert Race.last.last_tweet2.to_i > 0
    end
  end
  # Uncomment this once we don't perform on show.
  # context "on GET to :show" do
  #   setup do
  #     get :show, :id => Factory.(:race).id
  #   end
  #   should_respond_with :success
  #   should_render_template :show
  # end
  context "on GET to :edit" do
    setup do
      get :edit, :id => Factory(:race).id
    end
    should_respond_with :success
    should_render_template :edit
  end
  # context "on PUT to :update" do
  #   setup do
  #     @id = Factory(:race).id
  #     put :update, :id => @id, :race => {:count1 => 3}
  #   end
  #   # should_redirect_to "/races/#{Factory(:race).id}/show"
  #   should_respond_with :redirect
  #   should "keep the updated data" do
  #     assert Race.find(@id).count1 == 3
  #   end
  # end
  # context "on DELETE to :destroy" do
  #   setup do
  #     @id = Factory(:race).id
  #     post :destroy, :id => @id
  #   end
  #   should "delete the object" do
  #     assert_raises ActiveRecord::RecordNotFound do
  #       Race.find(@id)
  #     end
  #   end
  # end
end
