class MaterialComposition < ActiveRecord::Base
  belongs_to :material, class_name: 'Material', primary_key: :material_id, foreign_key: :material_id
  validate   :not_applicable

  def not_applicable
    errors.add(:composition_name, "Not applicable") if self.composition_name == "n/a"
  end
end
