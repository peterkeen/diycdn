class ApplicationController < ActionController::Base
  def authenticate_from_bearer_token!
    if request.env['HTTP_AUTHORIZATION']
      token = request.env['HTTP_AUTHORIZATION'].gsub(/^Bearer /, '')
      proxy = Proxy.find_by(api_key: token)
      if proxy
        @current_proxy = proxy
        @current_proxy.activate!
        return true
      end
    end

    head :unauthorized
  end
end
