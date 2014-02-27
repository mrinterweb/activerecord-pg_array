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

ActiveRecord::Schema.define(version: 20140227091226) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "wolf_trackers", force: true do |t|
    t.string  "name"
    t.integer "wolf_ids",   default: [], array: true
    t.string  "pack_names", default: [], array: true
    t.string  "chicken_ids",  default: [], array: true # this is intentionally an array of strings
  end

  add_index "wolf_trackers", ["wolf_ids"], name: "index_wolf_trackers_on_wolf_ids", using: :gin

  create_table "wolves", force: true do |t|
    t.string "name"
  end

end
