class CreateProxies < ActiveRecord::Migration[5.2]
  def change
    create_table :proxies do |t|
      t.string :external_hostname
      t.string :internal_hostname
      t.string :api_key

      t.timestamps
    end
  end
end
