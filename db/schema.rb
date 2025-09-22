# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2023_12_01_000003) do
  create_table "api_keys", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "key", null: false
    t.text "description"
    t.datetime "expires_at"
    t.datetime "revoked_at"
    t.datetime "last_used_at"
    t.integer "usage_count", default: 0
    t.text "permissions", size: :long, default: "{}", collation: "utf8mb4_bin"
    t.string "created_by_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_api_keys_on_expires_at"
    t.index ["key"], name: "index_api_keys_on_key", unique: true
    t.index ["revoked_at", "expires_at"], name: "index_api_keys_on_active"
    t.index ["revoked_at"], name: "index_api_keys_on_revoked_at"
    t.check_constraint "json_valid(`permissions`)", name: "permissions"
  end

  create_table "short_urls", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "full_url"
    t.string "title"
    t.integer "click_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_code"
    t.datetime "deleted_at"
    t.string "created_by_ip"
    t.datetime "last_accessed_at"
    t.string "custom_alias", limit: 32
    t.datetime "expires_at"
    t.text "metadata", size: :long, collation: "utf8mb4_bin"
    t.string "password_digest"
    t.integer "max_clicks"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_campaign"
    t.index ["click_count", "created_at"], name: "index_short_urls_on_popularity"
    t.index ["custom_alias"], name: "index_short_urls_on_custom_alias", unique: true
    t.index ["deleted_at"], name: "index_short_urls_on_deleted_at"
    t.index ["expires_at"], name: "index_short_urls_on_expires_at"
    t.index ["full_url"], name: "index_short_urls_on_full_url"
    t.index ["short_code"], name: "index_short_urls_on_short_code", unique: true
    t.check_constraint "`expires_at` is null or `expires_at` > `created_at`", name: "check_expires_after_creation"
    t.check_constraint "json_valid(`metadata`)", name: "metadata"
  end

end
