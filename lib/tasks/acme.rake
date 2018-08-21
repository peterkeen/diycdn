require 'openssl'

namespace :acme do
  task :initialize => :environment do
    private_key = OpenSSL::PKey::RSA.new(4096)

    puts "Private key"
    puts private_key.to_pem.to_s

    File.open(ENV['ACME_PRIVATE_KEY_PATH'], 'w+') do |f|
      f.write private_key.to_pem.to_s
    end

    client = Acme::Client.new(private_key: private_key, directory: ENV['ACME_DIRECTORY'])

    account = client.new_account(contact: "mailto:#{ENV['ACME_ACCOUNT_EMAIL']}", terms_of_service_agreed: true)

    puts "Account KID"
    puts account.kid
  end

  task :verify => :environment do
    private_key = OpenSSL::PKey::RSA.new(File.read(ENV['ACME_PRIVATE_KEY_PATH']))
    client = Acme::Client.new(private_key: private_key, directory: ENV['ACME_DIRECTORY'])
    puts client.kid
  end
end
