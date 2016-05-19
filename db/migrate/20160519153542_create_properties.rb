class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.integer     :material_id, index: true, null: false
      t.string      :property_name
      t.datetime    :dtime
      t.foreign_key :materials, column: :material_id
    end
  end
end
