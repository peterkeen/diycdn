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

ActiveRecord::Schema.define(version: 2018_09_02_153120) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "proxies", force: :cascade do |t|
    t.string "external_hostname"
    t.string "internal_hostname"
    t.string "api_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_seen_at"
    t.boolean "certificates_only"
    t.string "aasm_state", default: "active"
    t.boolean "needs_setup", default: false
  end

  create_table "sites", force: :cascade do |t|
    t.string "name"
    t.text "domain_list"
    t.text "certificate"
    t.text "private_key"
    t.datetime "expires_at"
    t.text "upstream"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "push", default: false
    t.string "s3_bucket"
    t.string "s3_access_key_id"
    t.string "s3_secret_access_key"
  end

end
