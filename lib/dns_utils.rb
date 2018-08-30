require 'resolv'

module DnsUtils
  class << self
    def nameservers(domain)
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

    def records(label, type, nameserver='8.8.8.8')
      Resolv::DNS.open(nameserver: nameserver) do |dns|
        dns.getresources(label, type)
      end
    end
  end
end
