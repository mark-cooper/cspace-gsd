class Material < ActiveRecord::Base
  has_many :material_compositions, primary_key: :material_id, foreign_key: :material_id
  has_many :material_forms,        primary_key: :material_id, foreign_key: :material_id
  has_many :material_processes,    primary_key: :material_id, foreign_key: :material_id
  has_many :material_properties,   primary_key: :material_id, foreign_key: :material_id

  belongs_to :vendor, primary_key: :vendor_id, foreign_key: :vendor_id

  before_save :sanitize

  scope :material_process_types,  -> {
    # icky -- additional a is process group (exception)
    MaterialMap.where(table: 'process').where.not(material_type: 'additional').pluck(:material_type).uniq.compact
  }

  scope :material_property_types, -> {
    # yucky -- lfc is an exception
    MaterialMap.where(table: 'property').where.not(material_type: 'lifecycleComponent').pluck(:material_type).uniq.compact
  }

  # if there is a (material_form a.k.a common_form) return the cspace term if matched to gsd term
  def common_forms
    forms(:material_form, :cspace_term, :cspace_label)
  end

  # if there is a (material_type a.k.a form_type) return the material type if matched to gsd term
  def form_types
    forms(:material_type, :material_type, :material_label)
  end

  def forms(map_field, map_id, map_ref)
    map       = MaterialMap.where(table: 'form')
    forms     = self.material_forms.map { |f| f.form_name }.uniq
    terms     = add_terms map, forms, map_field, map_id, map_ref
    terms
  end

  def lifecycle_components
    map        = MaterialMap.where(table: 'property').where(material_type: 'lifecycleComponent')
    properties = self.material_properties.map { |p| p.property_name }.uniq
    terms      = add_terms map, properties, :cspace_term, :cspace_term, :cspace_label
    terms
  end

  # get processes by type if matched to gsd term
  # additional_processes = self.processes_by_type "additional"
  # joining_processes    = self.processes_by_type "joining"
  def processes_by_type(material_type)
    map       = MaterialMap.where(table: 'process', material_type: material_type)
    processes = self.material_processes.map { |p| p.process_name }.uniq
    terms     = add_terms map, processes, :cspace_term, :cspace_term, :cspace_label
    terms
  end

  # get properties by type if matched to gsd term
  # smart_material_properties      = self.properties_by_type "smartMaterial"
  # lifecycle_component_properties = self.properties_by_type "lifecycleComponent"
  def properties_by_type(material_type)
    map        = MaterialMap.where(table: 'property', material_type: material_type)
    properties = self.material_properties.map { |p| p.property_name }.uniq
    terms      = add_terms map, properties, :cspace_term, :cspace_term, :cspace_label
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

          CollectionSpace::XML.add xml, 'shortIdentifier', self.material_id

          CollectionSpace::XML.add_group xml, 'materialTerm', {
            'termDisplayName' => self.material_name,
            'termStatus'      => self.publish == 'Published' ? 'accepted' : 'under review',
            'termPrefForLang' => 'false',
          }

          # PROCESSES
          Material.material_process_types.each do |process_type|
            processes = self.processes_by_type process_type
            CollectionSpace::XML.add_processes xml, process_type, processes
          end

          # PROCESS GROUPS -- additional is the exception
          processes = self.processes_by_type 'additional'
          CollectionSpace::XML.add_processes_group xml, 'additional', processes

          # PROPERTIES
          Material.material_property_types.each do |property_type|
            properties = self.properties_by_type property_type
            CollectionSpace::XML.add_properties_group xml, property_type, properties
          end

          # LIFECYCLE COMPONENTS
          components = self.lifecycle_components
          CollectionSpace::XML.add_lifecycle_components_group xml, components
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

  def add_terms(map, original_terms, map_field, map_id, map_ref)
    mapped_terms = []
    original_terms.each { |t|
      map.each { |m| mapped_terms << [ m.send(map_id), m.send(map_ref) ] if m.send(map_field) and m.gsd_term == t }
    }
    mapped_terms
  end
end
