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

ActiveRecord::Schema.define(version: 20150221233909) do

  create_table "api_keys", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "purpose"
    t.string   "key"
    t.string   "key_hint"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "api_keys", ["user_id"], name: "index_api_keys_on_user_id"

  create_table "group_memberships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "roll"
    t.string   "state"
  end

  add_index "group_memberships", ["group_id"], name: "index_group_memberships_on_group_id"
  add_index "group_memberships", ["user_id"], name: "index_group_memberships_on_user_id"

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.string   "state"
    t.text     "settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "login_sessions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "key"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "login_sessions", ["user_id"], name: "index_login_sessions_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "display_name"
    t.string   "username"
    t.string   "email"
    t.string   "password_digest"
    t.string   "state"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
