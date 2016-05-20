class CreateMaterialMaps < ActiveRecord::Migration
  def change
    create_table :material_maps do |t|
      t.string :table,    null: false
      t.string :gsd_term, null: false
      t.string :cspace_term
      t.string :cspace_label
      t.string :material_form
      t.string :material_type
      t.string :material_label
    end
  end
end
