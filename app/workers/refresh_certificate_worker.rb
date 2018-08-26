class RefreshCertificateWorker
  include Sidekiq::Worker

  class AuthSet
    attr_accessor :label, :record_type, :values

    def initialize(label, record_type)
      @label = label
      @record_type = record_type
      @values = Set.new([])
    end

    def matches_zone_name?(zone_name)
      (label + '.').ends_with?(zone_name)
    end
  end

  attr_reader :site

  def perform(site_id)
    @site = Site.find(site_id)

    key = OpenSSL::PKey::RSA.new(File.read(ENV['ACME_PRIVATE_KEY_PATH']))
    client = Acme::Client.new(private_key: key, directory: ENV['ACME_DIRECTORY'])
    domain_list = site.domains

    order = client.new_order(identifiers: domain_list)

    authorizations = build_auth_sets_from_order(order)

    route53 = Aws::Route53::Client.new(
      region: 'us-east-1'
    )

    zones = route53.list_hosted_zones(max_items: 100).hosted_zones

    zones.each do |zone|
      auths = authorizations.select { |a| a.matches_zone_name?(zone.name) }

      next if auths.length == 0

      # wildcards give multiple values so we have to build multiple resource records for a given name

      changes = auths.map do |auth|
        {
          action: "UPSERT",
          resource_record_set: {
            name: auth.label,
            type: auth.record_type,
            ttl: 1,
            resource_records: auth.values.map { |v|
              { value: %Q{"#{v}"} }
            }
          }
        }
      end

      opts = {
        hosted_zone_id: zone.id,
        change_batch: {
          changes: changes
        }
      }

      route53.change_resource_record_sets(opts)
    end

    Rails.logger.info "action=refresh site=#{site.id} status=waiting_for_dns"
    sleep 1 while !check_dns(authorizations)

    order.authorizations.each do |auth|
      auth.dns.request_validation
    end

    Rails.logger.info "action=refresh site=#{site.id} status=waiting_for_challenge"
    while true
      statuses = Set.new(order.authorizations.map { |a| a.dns.reload; a.dns.status })
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
      nameservers = get_nameservers(auth.label)

      nameservers.each do |ns|
        Resolv::DNS.open(nameserver: ns) do |dns|
          Rails.logger.debug "action=refresh site=#{site.id} resolve=checking name=#{auth.label} ns=#{ns}"
          begin
            resources = dns.getresources(auth.label, Resolv::DNS::Resource::IN::TXT).map(&:strings).flatten
            
            valid = auth.values == Set.new(resources)
          rescue Resolv::ResolvError
            Rails.logger.debug "action=refresh site=#{site.id} resolve=error name=#{auth.label} ns=#{ns}"
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


  def build_auth_sets_from_order(order)
    auth_sets = {}

    order.authorizations.each do |authorization|
      label = "_acme-challenge.#{authorization.identifier['value']}"
      record_type = authorization.dns.record_type
      value = authorization.dns.record_content

      auth_sets[label] ||= AuthSet.new(label, record_type)
      auth_sets[label].values.add(value)
    end

    auth_sets.values
  end
  
end
