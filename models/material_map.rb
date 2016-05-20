class MaterialMap < ActiveRecord::Base
  before_save :material_empty_or_manually_to_nil
  before_save :add_labels

  validate    :cspace_term_do_not_migrate

  private

  def add_labels
    self.cspace_label = MaterialMap.instance_vocabularies.fetch(self.cspace_term) if self.cspace_term

    if self.material_type and self.table == "form"
      self.material_label = MaterialMap.instance_vocabularies.fetch(self.material_type)
    end
  end

  def cspace_term_do_not_migrate
    if self.cspace_term and self.cspace_term =~ /do not migrate/i
      errors.add(:cspace_term, "Do not migrate")
    end
  end

  def material_empty_or_manually_to_nil
    [:material_form, :material_type].each do |m|
      if self.send(m) and (self.send(m).empty? or self.send(m) =~ /GSD manually/i)
        self.send("#{m}=", nil)
      end
    end
  end

  def self.instance_vocabularies
    @@iv     ||= Nokogiri::XML(open(Nrb.config.vocabularies_url))
    @@iv_map ||= {}

    if @@iv_map.empty?
      @@iv.css("option").each do |x|
        @@iv_map[ x.attributes['id'].value ] = x.text if x.attributes.has_key? 'id'
      end
    end

    @@iv_map
  end
end
