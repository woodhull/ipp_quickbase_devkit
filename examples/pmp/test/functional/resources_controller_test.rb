require File.dirname(__FILE__) + '/../test_helper'
require 'resources_controller'

# Re-raise errors caught by the controller.
class ResourcesController; def rescue_action(e) raise e end; end

class ResourcesControllerTest < Test::Unit::TestCase
  def setup
    @controller = ResourcesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
