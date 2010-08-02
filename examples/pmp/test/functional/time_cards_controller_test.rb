require File.dirname(__FILE__) + '/../test_helper'
require 'time_cards_controller'

# Re-raise errors caught by the controller.
class TimeCardsController; def rescue_action(e) raise e end; end

class TimeCardsControllerTest < Test::Unit::TestCase
  def setup
    @controller = TimeCardsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
