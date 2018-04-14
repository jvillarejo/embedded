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

ActiveRecord::Schema.define(version: 20170825185716) do

  create_table "orders", force: :cascade do |t|
    t.string "price_currency"
    t.decimal "price_amount"
    t.string "weight_magnitude"
    t.decimal "weight_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people", force: :cascade do |t|
    t.string "id_number"
    t.string "id_type"
  end

  create_table "reservations", force: :cascade do |t|
    t.datetime "time_interval_start_time"
    t.datetime "time_interval_end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
