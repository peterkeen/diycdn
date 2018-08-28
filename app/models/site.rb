require 'resolv'

class Site < ApplicationRecord
  after_commit :refresh_certificate!, if: :saved_change_to_domain_list?

  scope :with_certificate, -> {where('certificate is not null and certificate != ?', '') }

  scope :configurable -> {
    with_certificate
      .where('(upstream is not null and upstream != ?) or push', '')
  }

  def refresh_certificate!
    RefreshCertificateWorker.perform_async(self.id)
  end

  def server_name
    domain_list.split(/\s+/).join(' ')
  end

  def upstream_name
    "upstream-site-#{id}"
  end

  def upstream_server
    uri = URI(upstream)

    if uri.port.nil?
      if uri.scheme == 'https'
        port = '443'
      else
        port = '80'
      end
    else
      port = uri.port
    end

    "#{uri.host}:#{port}"
  end

  def upstream_scheme
    URI(upstream).scheme
  end

  def domains
    domain_list.split(/\s+/).map(&:strip)    
  end
end
