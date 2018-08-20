class RefreshCertificateWorker
  include Sidekiq::Worker

  attr_reader :site

  def perform(site_id)
    @site = Site.find(site_id)

    key = OpenSSL::PKey::RSA.new(Rails.application.credentials[Rails.env.to_sym][:acme_private_key])
    client = Acme::Client.new(private_key: key, directory: Rails.application.credentials[Rails.env.to_sym][:acme_directory])
    domain_list = site.domain_list.split(/\s+/).map(&:strip)

    order = client.new_order(identifiers: domain_list)

    authorizations = order.authorizations

    route53 = Aws::Route53::Client.new(
      region: 'us-east-1',
      access_key_id: Rails.application.credentials[Rails.env.to_sym][:aws_access_key_id],
      secret_access_key: Rails.application.credentials[Rails.env.to_sym][:aws_secret_access_key]
    )

    zones = route53.list_hosted_zones(max_items: 100).hosted_zones
    
    zones.each do |zone|
      auths = authorizations.select { |d| (d.identifier['value'] + '.').ends_with?(zone.name) }

      next if auths.length == 0

      changes = auths.map do |auth|
        challenge = auth.dns

        record_name = "#{challenge.record_name}.#{auth.identifier['value']}"
        {
          action: "UPSERT",
          resource_record_set: {
            name: record_name,
            type: challenge.record_type,
            ttl: 1,
            resource_records: [
              { value: %Q{"#{challenge.record_content}"} }
            ]
          }
        }
      end

      opts = {
        hosted_zone_id: zone.id,
        change_batch: {
          changes: changes
        }
      }

      pp route53.change_resource_record_sets(opts)
    end

    Rails.logger.info "action=refresh site=#{site.id} status=waiting_for_dns"
    sleep 1 while !check_dns(authorizations)

    authorizations.each do |auth|
      auth.dns.request_validation
    end

    Rails.logger.info "action=refresh site=#{site.id} status=waiting_for_challenge"
    while true
      statuses = Set.new(authorizations.map { |a| a.dns.reload; a.dns.status })
      if statuses.include?('pending')
        sleep(2)
        next
      else
        break
      end
    end

    cert_key = OpenSSL::PKey::RSA.new(4096)
    site.private_key = cert_key.to_pem.to_s
    csr = Acme::Client::CertificateRequest.new(private_key: cert_key, names: domain_list)
    order.finalize(csr: csr)

    Rails.logger.info "action=refresh site=#{site.id} status=waiting_for_certificate"
    sleep(1) while order.status == 'processing'

    site.certificate = order.certificate
    site.save!

    Rails.logger.info "action=refresh site=#{site.id} status=success"
  end

  def check_dns(authorizations)
    valid = true

    authorizations.each do |auth|
      domain = auth.identifier['value']
      value = auth.dns.record_content

      nameservers = get_nameservers(auth.identifier['value'])

      nameservers.each do |ns|
        Resolv::DNS.open(nameserver: ns) do |dns|
          resource_name = "_acme-challenge.#{domain}"
          Rails.logger.debug "action=refresh site=#{site.id} resolve=checking name=#{resource_name} ns=#{ns}"
          begin
            resource = dns.getresource(resource_name, Resolv::DNS::Resource::IN::TXT)
            pp [value, resource.strings[0]]
            valid = value == resource.strings[0]            
          rescue Resolv::ResolvError
            Rails.logger.debug "action=refresh site=#{site.id} resolve=error name=#{resource_name} ns=#{ns}"
            return false
          end

          return false if !valid
        end
      end
    end

    valid
  end

  def get_nameservers(domain)
    domain = domain.dup
    result = []

    Resolv::DNS.open(nameserver: '8.8.8.8') do |dns|
      while result.length == 0
        result = dns.getresources(domain, Resolv::DNS::Resource::IN::NS).map(&:name).map(&:to_s)
        domain = domain.split(/\./).drop(1).join('.')
      end
    end

    return result
  end
  
end
