class ScriptsController < ApplicationController
  before_action :authenticate_from_bearer_token!

  def setup
    render :setup, layout: false, content_type: 'text/plain'
  end

  def update
    render :update, layout: false, content_type: 'text/plain'
  end
end
