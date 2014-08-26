class AddIndexOnStargazersCount < ActiveRecord::Migration
  def change
    add_index :repos, :stargazers_count
  end
end
