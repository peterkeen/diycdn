class AddLastSeenAtToProxies < ActiveRecord::Migration[5.2]
  def change
    add_column :proxies, :last_seen_at, :timestamp
  end
end
