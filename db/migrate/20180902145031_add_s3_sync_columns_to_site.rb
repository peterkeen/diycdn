class AddS3SyncColumnsToSite < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :s3_bucket, :string
    add_column :sites, :s3_access_key_id, :string
    add_column :sites, :s3_secret_access_key, :string
  end
end
