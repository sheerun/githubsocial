# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140822143636) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "repos", force: true do |t|
    t.string   "name"
    t.string   "owner"
    t.text     "description"
    t.string   "homepage"
    t.integer  "parent_id"
    t.integer  "source_id"
    t.string   "language"
    t.datetime "pushed_at"
    t.integer  "stargazers_count"
    t.integer  "watchers_count"
    t.integer  "open_issues"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name",        limit: 1023
  end

  add_index "repos", ["full_name"], name: "index_repos_on_full_name", unique: true, using: :btree
  add_index "repos", ["full_name"], name: "repos_full_name_idx", using: :btree
  add_index "repos", ["name"], name: "repos_name_idx", using: :btree
  add_index "repos", ["owner"], name: "repos_owner_idx", using: :btree

  create_table "users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login"
    t.string   "gravatar_id"
    t.boolean  "site_admin"
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree

end
