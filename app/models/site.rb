require 'resolv'

class Site < ApplicationRecord
  after_commit :refresh_certificate!, if: :saved_change_to_domain_list?

  def refresh_certificate!
    RefreshCertificateWorker.perform_async(self.id)
  end
end
