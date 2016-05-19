class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.references  :material, index: true, null: false
      t.string      :property_name
      t.datetime    :dtime
    end

    add_foreign_key :materials, column: :material_id
  end
end
