require 'resolv'

class Proxy < ApplicationRecord
  before_create :update_api_key

  def update_api_key
    self.api_key = SecureRandom.uuid
  end

  def ipv4
    @ipv4s ||= Resolv::DNS.open(nameserver: '8.8.8.8') do |dns|
      dns.getresources(external_hostname, Resolv::DNS::Resource::IN::A).map(&:address).map(&:to_s)
    end
  end

  def ipv6
    @ipv6s ||= Resolv::DNS.open(nameserver: '8.8.8.8') do |dns|
      dns.getresources(external_hostname, Resolv::DNS::Resource::IN::AAAA).map(&:address).map(&:to_s)
    end    
  end

  def region
    external_hostname.split(/\./)[1]
  end
end
