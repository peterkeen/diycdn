class AddSkipHostHeaderToSite < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :skip_host_header, :boolean
  end
end
