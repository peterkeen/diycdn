class AddNeedsSetupToProxy < ActiveRecord::Migration[5.2]
  def change
    add_column :proxies, :needs_setup, :boolean, default: false
  end
end
