require 'resolv'

class Site < ApplicationRecord
  after_save :refresh_certificate!

  def refresh_certificate!
    RefreshCertificateWorker.perform_async(self.id) if domain_list_changed?
  end
end
