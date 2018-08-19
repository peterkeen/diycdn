class CreateSites < ActiveRecord::Migration[5.2]
  def change
    create_table :sites do |t|
      t.string :name
      t.text :domain_list
      t.text :certificate
      t.text :private_key
      t.timestamp :expires_at
      t.text :upstream

      t.timestamps
    end
  end
end
