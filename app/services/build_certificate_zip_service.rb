require 'zip'

class BuildCertificateZipService
  def self.call
    stringio = Zip::OutputStream.write_buffer do |zio|
      Site.with_certificate.find_each do |site|
        zio.put_next_entry("certificates/site-#{site.id}/fullchain.pem")
        zio.write(site.certificate)
        zio.put_next_entry("certificates/site-#{site.id}/privkey.pem")
        zio.write(site.private_key)
      end
    end

    stringio.string
  end
end
