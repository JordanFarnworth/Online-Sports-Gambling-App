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

ActiveRecord::Schema.define(version: 20150321214809) do

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
    t.string   "state"
    t.string   "role"
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

  create_table "lobbies", force: :cascade do |t|
    t.integer  "group_id"
    t.datetime "betting_begins_at"
    t.datetime "betting_ends_at"
    t.text     "settings"
    t.string   "state"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "lobbies", ["group_id"], name: "index_lobbies_on_group_id"

  create_table "login_sessions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "key"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "login_sessions", ["user_id"], name: "index_login_sessions_on_user_id"

  create_table "message_participants", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "message_id"
    t.string   "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "user_type"
  end

  add_index "message_participants", ["message_id"], name: "index_message_participants_on_message_id"
  add_index "message_participants", ["user_id"], name: "index_message_participants_on_user_id"

  create_table "messages", force: :cascade do |t|
    t.string   "subject"
    t.text     "body"
    t.string   "state"
    t.integer  "sender_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "messages", ["sender_id"], name: "index_messages_on_sender_id"

  create_table "monetary_transactions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "transaction_type"
    t.decimal  "amount",           precision: 6, scale: 2
    t.string   "state"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "monetary_transactions", ["user_id"], name: "index_monetary_transactions_on_user_id"

  create_table "page_views", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "real_user_id"
    t.string   "path"
    t.string   "ip_address"
    t.string   "http_method"
    t.text     "user_agent"
    t.text     "parameters"
    t.string   "referrer"
    t.string   "request_format"
    t.string   "controller"
    t.string   "action"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "page_views", ["real_user_id"], name: "index_page_views_on_real_user_id"
  add_index "page_views", ["user_id"], name: "index_page_views_on_user_id"

  create_table "payments", force: :cascade do |t|
    t.integer  "monetary_transaction_id"
    t.integer  "user_id"
    t.string   "uuid"
    t.string   "gateway"
    t.decimal  "amount",                  precision: 6, scale: 2
    t.string   "state"
    t.text     "parameters"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "payments", ["monetary_transaction_id"], name: "index_payments_on_monetary_transaction_id"
  add_index "payments", ["user_id"], name: "index_payments_on_user_id"

  create_table "role_memberships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.string   "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "role_memberships", ["role_id"], name: "index_role_memberships_on_role_id"
  add_index "role_memberships", ["user_id"], name: "index_role_memberships_on_user_id"

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.text     "permissions"
    t.string   "state"
    t.string   "protection_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "display_name"
    t.string   "username"
    t.string   "email"
    t.string   "password_digest"
    t.string   "state"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.decimal  "balance",         precision: 8, scale: 2
  end

end
