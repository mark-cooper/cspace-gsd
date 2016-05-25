class MaterialComposition < ActiveRecord::Base
  belongs_to  :material, class_name: 'Material', primary_key: :material_id, foreign_key: :material_id
  before_save :convert_to_lowercase

  validate   :not_applicable

  private

  def convert_to_lowercase
    self.composition_name = self.composition_name.downcase
  end

  def not_applicable
    errors.add(:composition_name, "Not applicable") if self.composition_name == "n/a"
  end
end
