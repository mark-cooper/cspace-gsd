class CreateMaterialCompositions < ActiveRecord::Migration
  def change
    create_table :material_compositions do |t|
      t.references :material, index: true, null: false
      t.string     :composition_name
      t.datetime   :dtime
    end

    add_foreign_key :materials, column: :material_id
  end
end
