class MaterialProperty < ActiveRecord::Base
  belongs_to :material, class_name: 'Material', primary_key: :material_id, foreign_key: :material_id
end
