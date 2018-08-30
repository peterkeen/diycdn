require 'dns_utils'

class RefreshRecordsWorker
  include Sidekiq::Worker

  def perform
    route53 = Aws::Route53::Client.new(
      region: 'us-east-1'
    )

    zones = route53.list_hosted_zones(max_items: 100).hosted_zones

    domains = Site.where("upstream is not null and upstream != ''").pluck(:domain_list).map { |dl| dl.split(/\s+/).map(&:strip) }.flatten
    proxies = Proxy.where('certificates_only is null or certificates_only = false').all

    zones.each do |zone|
      matches = domains.select { |d| (d + '.').ends_with?(zone.name) }

      changes = []
      matches.each do |match|
        proxies.each do |proxy|
          [['A', :ipv4], ['AAAA', :ipv6]].each do |record_type, method|
            changes << {
              action: 'UPSERT',
              resource_record_set: {
                name: match,
                type: record_type,
                ttl: 60,
                region: proxy.region,
                set_identifier: "zone #{zone.id} region #{proxy.region}",
                resource_records: proxy.send(method).map { |ip|
                  { value: ip }
                }
              }
            }
          end
        end
      end

      next if changes.length < 1

      opts = {
        hosted_zone_id: zone.id,
        change_batch: {
          changes: changes
        }
      }

      route53.change_resource_record_sets(opts)
    end
  end

  def change(label, proxy, record_type, method)
    if needs_delete?(label, proxy, record_type, method)
      {
        action: 'DELETE',
        resource_record_set: {
          name: match,
          type: record_type,
          ttl: 60,
          region: proxy.region,
          set_identifier: "zone #{zone.id} region #{proxy.region}",
          resource_records: proxy.send(method).map { |ip|
            { value: ip }
          }
        }
      }      
    else
      {
        action: 'UPSERT',
        resource_record_set: {
          name: match,
          type: record_type,
          ttl: 60,
          region: proxy.region,
          set_identifier: "zone #{zone.id} region #{proxy.region}",
          resource_records: proxy.send(method).map { |ip|
            { value: ip }
          }
        }
      }
    end
  end

  def needs_delete?(label, proxy, record_type, method)
    return false if proxy.active?

    record_class = {
      'A' => Resolv::DNS::Resource::IN::A,
      'AAAA' => Resolv::DNS::Resource::IN::AAAA
    }[record_type]

    nameserver = DnsUtils.nameservers(label).first
    ips = DnsUtils.records(label, record_class, nameserver: nameserver).map(&:address).map(&:to_s)

    proxy_ips = Set.new(proxy.send(method))

    ips.intersect?(proxy_ips)
  end
end
