class Proxy < ApplicationRecord
  before_create :update_api_key

  def update_api_key
    self.api_key = SecureRandom.uuid
  end
end
