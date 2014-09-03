require 'test_helper'

class WagersControllerTest < ActionController::TestCase
  setup do
    @wager = wagers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:wagers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wager" do
    assert_difference('Wager.count') do
      post :create, wager: { game_id: @wager.game_id, max_amount: @wager.max_amount, min_amount: @wager.min_amount, question: @wager.question, stream_id: @wager.stream_id }
    end

    assert_redirected_to wager_path(assigns(:wager))
  end

  test "should show wager" do
    get :show, id: @wager
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @wager
    assert_response :success
  end

  test "should update wager" do
    patch :update, id: @wager, wager: { game_id: @wager.game_id, max_amount: @wager.max_amount, min_amount: @wager.min_amount, question: @wager.question, stream_id: @wager.stream_id }
    assert_redirected_to wager_path(assigns(:wager))
  end

  test "should destroy wager" do
    assert_difference('Wager.count', -1) do
      delete :destroy, id: @wager
    end

    assert_redirected_to wagers_path
  end
end
