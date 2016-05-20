class Material < ActiveRecord::Base
  has_many :material_compositions, primary_key: :material_id, foreign_key: :material_id
  has_many :material_forms,        primary_key: :material_id, foreign_key: :material_id
  has_many :material_processes,    primary_key: :material_id, foreign_key: :material_id
  has_many :material_properties,   primary_key: :material_id, foreign_key: :material_id

  belongs_to :vendor, primary_key: :vendor_id, foreign_key: :vendor_id

  before_save :sanitize

  # self.common_forms
  scope :common_forms, -> {
    terms = [];
    map   = MaterialMap.find_by(table: 'form');
    forms = self.material_forms.map { |f| f.form_name }.uniq;
    forms.each { |f| map.each { |m| terms << m.cspace_term if m.form and m.gsd_term == f } }
  }

  # self.form_types
  scope :form_types, -> {
    terms = [];
    map   = MaterialMap.find_by(table: 'form');
    forms = self.material_forms.map { |f| f.form_name }.uniq;
    forms.each { |f| map.each { |m| terms << m.type if m.type and m.gsd_term == f } }
  }

  # additional_processes = self.processes_by_type "Additional Process"
  # joining_processes    = self.processes_by_type "Joining"
  scope :processes_by_type, ->(type) {
    terms     = [];
    map       = MaterialMap.find_by(table: 'process', type: type);
    processes = self.material_processes.map { |p| p.process_name }.uniq;
    processes.each { |p| map.each { |m| terms << m.cspace_term if m.gsd_term == p } };
    return terms;
  }

  # smart_material_properties      = self.properties_by_type "Smart material"
  # lifecycle_component_properties = self.properties_by_type "Lifecycle Component"
  scope :properties_by_type, ->(type) {
    terms      = [];
    map        = MaterialMap.find_by(table: 'property', type: type);
    properties = self.material_properties.map { |p| p.property_name }.uniq;
    properties.each { |p| map.each { |m| terms << m.cspace_term if m.gsd_term == p } };
    return terms;
  }

  def sanitize
    { 
      strip: [],
      squeeze: ["\n"],
      squeeze: [" "],
      gsub: [Regexp.new("(\n|\t)"), " "]
    }.each do |method, args|
      self.attributes.each { |a, v| self[a] = v.send method, *args if v.respond_to? method }
    end
  end

  def to_cspace_xml
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.document(name: 'materials') {
        xml.send(
          'ns2:materials_common',
          'xmlns:ns2' => 'http://collectionspace.org/services/material',
          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance'
        ) do
          # TODO: add based on cspace field names
          xml.materialTermGroupList {
            xml.materialTermGroup {
              xml.termDisplayName self.material_name
              xml.termStatus      self.publish == 'Published' ? 'accepted' : 'under review'
              xml.termPrefForLang 'false'
            }
          }
        end
      }
    end
    puts builder.to_xml
  end
end
