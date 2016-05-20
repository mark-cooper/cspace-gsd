class CreateMaterialMaps < ActiveRecord::Migration
  def change
    create_table :material_maps do |t|
      t.string :table,       null: false
      t.string :form
      t.string :type
      t.string :gsd_term,    null: false
      t.string :cspace_term, null: false
    end
  end
end
