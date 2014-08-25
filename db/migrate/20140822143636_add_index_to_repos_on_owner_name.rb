class AddIndexToReposOnOwnerName < ActiveRecord::Migration
  def change
    add_index :repos, :full_name, unique: true
  end
end
