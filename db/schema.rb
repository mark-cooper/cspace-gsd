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

ActiveRecord::Schema.define(version: 20160525233909) do

  create_table "concepts", force: :cascade do |t|
    t.string "display_name",    null: false
    t.string "record_type",     null: false
    t.string "broader_concept"
  end

  create_table "material_compositions", force: :cascade do |t|
    t.integer  "material_id",      null: false
    t.string   "composition_name"
    t.datetime "dtime"
  end

  add_index "material_compositions", ["material_id"], name: "index_material_compositions_on_material_id"

  create_table "material_forms", force: :cascade do |t|
    t.integer  "material_id", null: false
    t.string   "form_name"
    t.datetime "dtime"
  end

  add_index "material_forms", ["material_id"], name: "index_material_forms_on_material_id"

  create_table "material_maps", force: :cascade do |t|
    t.string "table",          null: false
    t.string "gsd_term",       null: false
    t.string "cspace_term"
    t.string "cspace_label"
    t.string "material_type"
    t.string "material_label"
  end

  create_table "material_processes", force: :cascade do |t|
    t.integer  "material_id",  null: false
    t.string   "process_name"
    t.datetime "dtime"
  end

  add_index "material_processes", ["material_id"], name: "index_material_processes_on_material_id"

  create_table "material_properties", force: :cascade do |t|
    t.integer  "material_id",   null: false
    t.string   "property_name"
    t.datetime "dtime"
  end

  add_index "material_properties", ["material_id"], name: "index_material_properties_on_material_id"

  create_table "materials", force: :cascade do |t|
    t.integer  "material_id",                    null: false
    t.string   "material_name"
    t.integer  "year_introduced"
    t.string   "generic_name"
    t.text     "description"
    t.string   "hollis_notes"
    t.string   "course_notes"
    t.integer  "vendor_id",          default: 0, null: false
    t.string   "accession_number"
    t.string   "library_location"
    t.string   "name_type"
    t.string   "parent_material_id"
    t.string   "publish"
    t.datetime "dtime"
    t.string   "photo_status"
    t.string   "editor"
  end

  add_index "materials", ["material_id"], name: "index_materials_on_material_id"
  add_index "materials", ["vendor_id"], name: "index_materials_on_vendor_id"

  create_table "vendors", force: :cascade do |t|
    t.integer  "vendor_id",      null: false
    t.string   "vendor_name"
    t.string   "website"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "country"
    t.string   "phone"
    t.string   "fax"
    t.string   "email"
    t.string   "contact"
    t.datetime "dtime"
  end

  add_index "vendors", ["vendor_id"], name: "index_vendors_on_vendor_id"

end
