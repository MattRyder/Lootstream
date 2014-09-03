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

ActiveRecord::Schema.define(version: 20140822000438) do

  create_table "balances", force: true do |t|
    t.integer  "user_id"
    t.integer  "stream_id"
    t.decimal  "balance",    precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "balances", ["stream_id"], name: "index_balances_on_stream_id"
  add_index "balances", ["user_id"], name: "index_balances_on_user_id"

  create_table "games", force: true do |t|
    t.string   "name"
    t.integer  "max_options"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "streams", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", force: true do |t|
    t.decimal  "amount"
    t.integer  "user_id"
    t.integer  "wager_option_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactions", ["user_id"], name: "index_transactions_on_user_id"
  add_index "transactions", ["wager_option_id"], name: "index_transactions_on_wager_option_id"

  create_table "users", force: true do |t|
    t.string   "access_token"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "wager_options", force: true do |t|
    t.string   "text"
    t.integer  "wager_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wager_options", ["wager_id"], name: "index_wager_options_on_wager_id"

  create_table "wagers", force: true do |t|
    t.string   "question"
    t.decimal  "min_amount"
    t.decimal  "max_amount"
    t.boolean  "active"
    t.datetime "suspended_at"
    t.integer  "game_id"
    t.integer  "stream_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wagers", ["game_id"], name: "index_wagers_on_game_id"
  add_index "wagers", ["stream_id"], name: "index_wagers_on_stream_id"

end
