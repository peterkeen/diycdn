require 'dns_utils'

class Proxy < ApplicationRecord
  include AASM  

  before_create :update_api_key

  aasm do
    state :new
    state :active
    state :inactive

    event :activate, after: :update_last_seen do
      transitions from: [:new, :inactive], to: :active
    end

    event :deactivate do
      transitions from: :active, to: :inactive
    end
  end

  def update_api_key
    self.api_key = SecureRandom.uuid
  end

  def ipv4
    @ipv4s ||= DnsUtils.records(external_hostname, Resolv::DNS::Resource::IN::A).map(&:address).map(&:to_s)
  end

  def ipv6
    @ipv6s ||= DnsUtils.records(external_hostname, Resolv::DNS::Resource::IN::AAAA).map(&:address).map(&:to_s)
  end

  def region
    external_hostname.split(/\./)[1]
  end

  def update_last_seen
    update_column :last_seen_at, Time.now.utc
  end
end
