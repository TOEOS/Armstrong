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

ActiveRecord::Schema.define(version: 20150816091144) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "articles", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "title"
    t.string   "arthor"
    t.datetime "post_at"
    t.text     "content"
    t.integer  "comments_count"
    t.text     "keywords"
    t.text     "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source_type"
    t.text     "pic_links"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "article_id"
    t.string   "commenter"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "commented_at"
  end

  create_table "events", force: :cascade do |t|
    t.text     "keywords"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "messages", force: :cascade do |t|
    t.text     "content",    null: false
    t.integer  "user_id",    null: false
    t.integer  "event_id",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "messages", ["event_id"], name: "index_messages_on_event_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "ptt_tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "raw_ptt_articles", force: :cascade do |t|
    t.string   "url"
    t.string   "title"
    t.boolean  "is_re"
    t.string   "author"
    t.datetime "date"
    t.text     "content"
    t.text     "signature_line"
    t.inet     "author_ip"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "ptt_tag_id"
  end

  add_index "raw_ptt_articles", ["ptt_tag_id"], name: "index_raw_ptt_articles_on_ptt_tag_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "image"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "raw_ptt_articles", "ptt_tags"
end
