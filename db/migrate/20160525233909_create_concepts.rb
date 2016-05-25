class CreateConcepts < ActiveRecord::Migration
  def change
    create_table :concepts do |t|
      t.string :display_name, null: false
      t.string :record_type, null: false
      t.string :broader_concept
    end
  end
end
