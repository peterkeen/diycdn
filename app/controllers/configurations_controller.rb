class ConfigurationsController < ApplicationController
  before_action :authenticate_from_bearer_token!

  def index
    render :index, layout: false, content_type: 'text/plain'
  end
end
