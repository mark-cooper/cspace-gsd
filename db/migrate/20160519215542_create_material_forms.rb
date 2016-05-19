class CreateMaterialForms < ActiveRecord::Migration
  def change
    create_table :material_forms do |t|
      t.references :material, index: true, null: false
      t.string     :form_name
      t.datetime   :dtime
    end

    add_foreign_key :materials, column: :material_id
  end
end
