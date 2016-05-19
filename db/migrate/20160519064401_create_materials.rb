class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.integer  :material_id, null: false
      t.string   :material_name
      t.integer  :year_introduced
      t.string   :generic_name
      t.text     :description
      t.string   :hollis_notes
      t.string   :course_notes
      t.integer  :vendor_id
      t.string   :accession_number
      t.string   :library_location
      t.string   :name_type
      t.string   :parent_material_id
      t.string   :publish
      t.datetime :dtime
      t.string   :photo_status
      t.string   :editor
    end
  end
end
