class AddPushToSites < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :push, :boolean, default: false
  end
end
