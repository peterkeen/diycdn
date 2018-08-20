class CertificatesController < ApplicationController
  before_action :authenticate_from_bearer_token!

  def index
    zip = BuildCertificateZipService.call

    send_data zip, filename: 'certificates.zip'
  end
end
