require 'resolv'

module DnsUtils
  class << self

    def default_name_server
      ENV.fetch('DEFAULT_NAME_SERVER', '8.8.8.8')
    end

    def nameservers(domain)
      domain = domain.dup
      result = []

      Resolv::DNS.open(nameserver: default_name_server) do |dns|
        while result.length == 0
          result = dns.getresources(domain, Resolv::DNS::Resource::IN::NS).map(&:name).map(&:to_s)
          domain = domain.split(/\./).drop(1).join('.')
        end
      end

      return result
    end

    def records(label, type, nameserver=nil)
      nameserver ||= default_name_server

      Resolv::DNS.open(nameserver: nameserver) do |dns|
        dns.getresources(label, type)
      end
    end
  end
end
