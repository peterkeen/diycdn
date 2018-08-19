require 'openssl'

namespace :acme do
  task :initialize => :environment do
    private_key = OpenSSL::PKey::RSA.new(4096)

    puts "Private key"
    puts private_key.to_pem.to_s

    client = Acme::Client.new(private_key: private_key, directory: 'https://acme-staging-v02.api.letsencrypt.org/directory')

    account = client.new_account(contact: 'mailto:apps@petekeen.net', terms_of_service_agreed: true)

    puts "Account KID"
    puts account.kid
  end

  task :verify => :environment do
    private_key = OpenSSL::PKey::RSA.new(Rails.application.credentials[Rails.env.to_sym][:acme_private_key])
    client = Acme::Client.new(private_key: private_key, directory: Rails.application.credentials[Rails.env.to_sym][:acme_directory])
    puts client.kid
  end
end
