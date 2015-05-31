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

ActiveRecord::Schema.define(version: 20150531123436) do

  create_table "activity_details", force: true do |t|
    t.integer  "event_id"
    t.string   "name"
    t.string   "icon"
    t.integer  "price"
    t.string   "price_per_unit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "minimum_count"
    t.integer  "maximum_count"
    t.string   "price_unit",     limit: 20
  end

  add_index "activity_details", ["event_id"], name: "index_activity_details_on_event_id", using: :btree

  create_table "availabilities", force: true do |t|
    t.integer  "participant_id"
    t.integer  "slot_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "availabilities", ["participant_id"], name: "index_availabilities_on_participant_id", using: :btree
  add_index "availabilities", ["slot_id", "participant_id"], name: "index_availabilities_on_slot_id_and_participant_id", unique: true, using: :btree
  add_index "availabilities", ["slot_id"], name: "index_availabilities_on_slot_id", using: :btree

  create_table "events", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "voting_deadline"
    t.integer  "manager_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "events", ["manager_id"], name: "index_events_on_manager_id", using: :btree
  add_index "events", ["slug"], name: "index_events_on_slug", unique: true, using: :btree

  create_table "participants", force: true do |t|
    t.text     "note"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
  end

  add_index "participants", ["event_id"], name: "index_participants_on_event_id", using: :btree
  add_index "participants", ["user_id"], name: "index_participants_on_user_id", using: :btree

  create_table "preference_condition_participants1", force: true do |t|
    t.integer  "preference_condition_id"
    t.integer  "participant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preference_condition_participants1", ["participant_id"], name: "index_preference_condition_participants1_on_participant_id", using: :btree
  add_index "preference_condition_participants1", ["preference_condition_id"], name: "preference_condition_participants1_condition_id_index", using: :btree

  create_table "preference_condition_participants2", force: true do |t|
    t.integer  "preference_condition_id"
    t.integer  "participant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preference_condition_participants2", ["participant_id"], name: "index_preference_condition_participants2_on_participant_id", using: :btree
  add_index "preference_condition_participants2", ["preference_condition_id"], name: "preference_condition_participants2_condition_id_index", using: :btree

  create_table "preference_conditions", force: true do |t|
    t.string   "condition_type"
    t.integer  "participant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preference_conditions", ["participant_id"], name: "index_preference_conditions_on_participant_id", using: :btree

  create_table "preference_prioritizations", force: true do |t|
    t.integer  "participant_id"
    t.integer  "for_participant_id"
    t.integer  "multiplier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preference_prioritizations", ["for_participant_id"], name: "index_preference_prioritizations_on_for_participant_id", using: :btree
  add_index "preference_prioritizations", ["participant_id"], name: "index_preference_prioritizations_on_participant_id", using: :btree

  create_table "slots", force: true do |t|
    t.integer  "event_id"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "time_detail_id"
    t.integer  "activity_detail_id"
  end

  add_index "slots", ["activity_detail_id"], name: "index_slots_on_activity_detail_id", using: :btree
  add_index "slots", ["event_id"], name: "index_slots_on_event_id", using: :btree
  add_index "slots", ["time_detail_id"], name: "index_slots_on_time_detail_id", using: :btree

  create_table "time_details", force: true do |t|
    t.integer  "event_id"
    t.datetime "from"
    t.datetime "until"
    t.string   "duration_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "time_details", ["event_id"], name: "index_time_details_on_event_id", using: :btree

  create_table "users", force: true do |t|
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
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
