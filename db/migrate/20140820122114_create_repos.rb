class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string :name
      t.string :owner
      t.text :description
      t.string :homepage
      t.integer :parent_id
      t.integer :source_id
      t.string :language
      t.datetime :pushed_at
      t.integer :stargazers_count
      t.integer :watchers_count
      t.integer :open_issues

      t.timestamps
    end
  end
end
