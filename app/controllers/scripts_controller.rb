class ScriptsController < ApplicationController
  before_action :authenticate_from_bearer_token!

  def setup
    @current_proxy.update_column(needs_setup: false)
    render :setup, layout: false, content_type: 'text/plain'
  end

  def update
    if params[:m]
      last_modified = Time.at(params[:m].to_i).utc
      @should_update = [Proxy.maximum(:updated_at).utc, Site.maximum(:updated_at).utc, File.mtime(Rails.root).utc].max > last_modified
    else
      @should_update = true
    end
    
    render :update, layout: false, content_type: 'text/plain'
  end
end
