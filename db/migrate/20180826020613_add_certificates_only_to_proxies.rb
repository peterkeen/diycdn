class AddCertificatesOnlyToProxies < ActiveRecord::Migration[5.2]
  def change
    add_column :proxies, :certificates_only, :boolean
  end
end
