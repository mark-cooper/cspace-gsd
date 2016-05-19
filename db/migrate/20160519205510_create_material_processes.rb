class CreateMaterialProcesses < ActiveRecord::Migration
  def change
    create_table :material_processes do |t|
      t.references :material, index: true, null: false
      t.string     :process_name
      t.datetime   :dtime
    end

    add_foreign_key :materials, column: :material_id
  end
end
