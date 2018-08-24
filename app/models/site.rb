require 'resolv'

class Site < ApplicationRecord
  after_commit :refresh_certificate!, if: :saved_change_to_domain_list?

  scope :with_upstream, -> { where('upstream is not null and upstream != ?', '') }

  def refresh_certificate!
    RefreshCertificateWorker.perform_async(self.id)
  end

  def server_name
    domain_list.split(/\s+/).join(' ')
  end

  def upstream_name
    "upstream-site-#{id}"
  end
end
