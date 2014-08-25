class AddFieldsToUsers < ActiveRecord::Migration
  def change
    remove_column :users, :data 

    add_column :users, :login, :string
    add_column :users, :gravatar_id, :string
    add_column :users, :site_admin, :boolean
  end
end
