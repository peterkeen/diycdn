class AddStateToSiteAndProxy < ActiveRecord::Migration[5.2]
  def change
    add_column :proxies, :aasm_state, :string, default: 'active'
  end
end
