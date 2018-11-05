class RefreshAllCertificatesWorker
  include Sidekiq::Worker

  def perform
    Site.find_each do |site|
      certificate = OpenSSL::X509::Certificate.new site.certificate
      next unless certificate.not_after < (Date.today + 30.days)

      RefreshCertificateWorker.perform_async(site.id)
    end
  end
end
