class Site < ApplicationRecord
  def refresh_certificate!
    key = OpenSSL::PKey::RSA.new(Rails.application.credentials[Rails.env.to_sym][:acme_private_key])    
    client = Acme::Client.new(private_key: key, directory: Rails.application.credentials[Rails.env.to_sym][:acme_directory])

    order = client.new_order(identifiers: self.domain_list.split(/\s+/).map(&:strip))

    authorization = order.authorizations.first
    challenge = authorization.dns

    pp [challenge.record_name, challenge.record_type, challenge.record_content]

    # find each domain in route53
    # set _acme-challenge TXT to the value
    # https://github.com/peterkeen/route53_ddns/blob/master/updater.rb    
    # request validation
    # sleep loop until verified
    # make a private key and CSR and request a certificate
    # stuff certificate, private key, and expires_at into database
  end
end
