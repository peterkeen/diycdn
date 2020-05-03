require 'dns_utils'

class RefreshRecordsWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    route53 = Aws::Route53::Client.new(
      region: 'us-east-1'
    )

    zones = route53.list_hosted_zones(max_items: 100).hosted_zones

    domains = Site.where("(upstream is not null and upstream != '') or (s3_bucket is not null and s3_bucket != '')").pluck(:domain_list).map { |dl| dl.split(/\s+/).map(&:strip) }.flatten
    proxies = Proxy.where('certificates_only is null or certificates_only = false').all

    zones.each do |zone|
      matches = domains.select { |d| (d + '.').ends_with?(zone.name) }

      changes = []
      matches.each do |match|
        [['A', :ipv4], ['AAAA', :ipv6]].each do |record_type, method|
          proxies.each do |proxy|
            changes << change(match, proxy, record_type, method, zone, route53)
          end

          changes += clean_old_proxy_records(match, proxies, record_type, method, zone, route53)
        end
      end

      next if changes.length < 1

      opts = {
        hosted_zone_id: zone.id,
        change_batch: {
          changes: changes
        }
      }

      begin
        route53.change_resource_record_sets(opts)
      rescue => e
        Rails.logger.error(e)
      end
    end
  end

  def clean_old_proxy_records(label, proxies, record_type, method, zone, route53)
    all_records = route53.list_resource_record_sets(hosted_zone_id: zone.id, start_record_type: record_type, start_record_name: label).map(&:resource_record_sets).flatten.select { |r| r.type == record_type }.map { |r| r.resource_records }

    all_records.group_by(&:region).map do |region, records|
      all_known_ips = proxies.where(region: region).map { |p| p.send(method) }

      records_to_delete = records.reject { |r| all_known_ips.include?(r.value) }

      if records_to_delete.length == 0
        nil
      else
        {
          action: 'DELETE',
          resource_record_set: {
            name: label,
            type: record_type,
            ttl: 60,
            region: region,
            set_identifier: "zone #{zone.id} region #{proxy.region} cleaner",
            resource_records: records_to_delete.map { |r|
              { value: r.value }
            }
          }
        }
      end
    end.compact
  end

  def change(label, proxy, record_type, method, zone, route53)
    proxy_ips = proxy.send(method)

    if needs_delete?(label, proxy, record_type, method, zone, route53)
      {
        action: 'DELETE',
        resource_record_set: {
          name: label,
          type: record_type,
          ttl: 60,
          region: proxy.region,
          set_identifier: "zone #{zone.id} region #{proxy.region}",
          resource_records: proxy_ips.map { |ip|
            { value: ip }
          }
        }
      }
    else
      {
        action: 'UPSERT',
        resource_record_set: {
          name: label,
          type: record_type,
          ttl: 60,
          region: proxy.region,
          set_identifier: "zone #{zone.id} region #{proxy.region}",
          resource_records: proxy_ips.map { |ip|
            { value: ip }
          }
        }
      }
    end
  end

  def needs_delete?(label, proxy, record_type, method, zone, route53)
    return false if proxy.active?

    ips = route53.list_resource_record_sets(hosted_zone_id: zone.id, start_record_type: record_type, start_record_name: label).map(&:resource_record_sets).flatten.select { |r| r.type == record_type }.map { |r| r.resource_records }.flatten.map(&:value)

    proxy_ips = Set.new(proxy.send(method))

    Set.new(ips).intersect?(proxy_ips)
  end
end
