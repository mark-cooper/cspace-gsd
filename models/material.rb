class Material < ActiveRecord::Base
  has_many :material_compositions, primary_key: :material_id, foreign_key: :material_id
  has_many :material_forms,        primary_key: :material_id, foreign_key: :material_id
  has_many :material_processes,    primary_key: :material_id, foreign_key: :material_id
  has_many :material_properties,   primary_key: :material_id, foreign_key: :material_id

  belongs_to :vendor, primary_key: :vendor_id, foreign_key: :vendor_id

  before_save :sanitize

  # if there is a (material_form a.k.a common_form) return the cspace term if matched to gsd term
  def common_forms
    forms :material_form, :cspace_term, :cspace_label
  end

  # if there is a (material_type a.k.a form_type) return the material type if matched to gsd term
  def form_types
    forms :material_type, :material_type, :material_label
  end

  def forms(map_field, map_id, map_ref)
    terms     = []
    map       = MaterialMap.where(table: 'form')
    forms     = self.material_forms.map { |f| f.form_name }.uniq
    forms.each { |f| map.each { |m| terms << [ m.send(map_id), m.send(map_ref) ] if m.send(map_field) and m.gsd_term == f } }
    terms
  end

  # get processes by type if matched to gsd term
  # additional_processes = self.processes_by_type "Additional Process"
  # joining_processes    = self.processes_by_type "Joining"
  def processes_by_type(material_type)
    terms     = []
    map       = MaterialMap.where(table: 'process', material_type: material_type)
    processes = self.material_processes.map { |p| p.process_name }.uniq
    processes.each { |p|
      map.each { |m| terms << [ m.cspace_term, m.cspace_label ] if m.cspace_term and m.gsd_term == p }
    }
    terms
  end

  # get properties by type if matched to gsd term
  # smart_material_properties      = self.properties_by_type "Smart material"
  # lifecycle_component_properties = self.properties_by_type "Lifecycle Component"
  def properties_by_type(material_type)
    terms      = []
    map        = MaterialMap.where(table: 'property', material_type: material_type)
    properties = self.material_properties.map { |p| p.property_name }.uniq
    properties.each { |p|
      map.each { |m| terms << [ m.cspace_term, m.cspace_label ] if m.cspace_term and m.gsd_term == p }
    }
    terms
  end

  def to_cspace_xml
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.document(name: 'materials') {
        xml.send(
          'ns2:materials_common',
          'xmlns:ns2' => 'http://collectionspace.org/services/material',
          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance'
        ) do
          # applying namespace breaks import
          xml.parent.namespace = nil

          xml.materialTermGroupList {
            xml.materialTermGroup {
              xml.termDisplayName self.material_name
              xml.termStatus      self.publish == 'Published' ? 'accepted' : 'under review'
              xml.termPrefForLang 'false'
            }
          }

          # PROPERTIES
          durability_properties = self.properties_by_type('Durability')
          if durability_properties.any?
            xml.durabilityPropertyGroupList {
              durability_properties.each do |durability_property|
                xml.durabilityPropertyGroup {
                  xml.durabilityPropertyType Utils::URN.generate(Nrb.config.domain, "vocabularies", "durabilityproperties", durability_property[0], durability_property[1])
                }
              end
            }
          end
        end
      }
    end
    puts builder.to_xml
  end

  private

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
end
