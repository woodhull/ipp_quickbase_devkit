require File.dirname(__FILE__) + '/../test_helper'
require 'document_library_controller'

# Re-raise errors caught by the controller.
class DocumentLibraryController; def rescue_action(e) raise e end; end

class DocumentLibraryControllerTest < Test::Unit::TestCase
  def setup
    @controller = DocumentLibraryController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
