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

  # if there is a common_form (cspace_term from 'form' table) return the cspace term if matched to gsd term
  def common_forms
    forms(:cspace_term, :cspace_label)
  end

  # if there is a (material_type a.k.a form_type) return the material type if matched to gsd term
  def form_types
    forms(:material_type, :material_label)
  end

  def forms(map_id, map_ref)
    map       = MaterialMap.where(table: 'form')
    forms     = self.material_forms.map { |f| f.form_name }.uniq
    terms     = add_terms map, forms, map_id, map_ref
    terms
  end

  def lifecycle_components
    map        = MaterialMap.where(table: 'property').where(material_type: 'lifecycleComponent')
    properties = self.material_properties.map { |p| p.property_name }.uniq
    terms      = add_terms map, properties, :cspace_term, :cspace_label
    terms
  end

  # get processes by type if matched to gsd term
  # additional_processes = self.processes_by_type "additional"
  # joining_processes    = self.processes_by_type "joining"
  def processes_by_type(material_type)
    map       = MaterialMap.where(table: 'process', material_type: material_type)
    processes = self.material_processes.map { |p| p.process_name }.uniq
    terms     = add_terms map, processes, :cspace_term, :cspace_label
    terms
  end

  # get properties by type if matched to gsd term
  # smart_material_properties      = self.properties_by_type "smartMaterial"
  # lifecycle_component_properties = self.properties_by_type "lifecycleComponent"
  def properties_by_type(material_type)
    map        = MaterialMap.where(table: 'property', material_type: material_type)
    properties = self.material_properties.map { |p| p.property_name }.uniq
    terms      = add_terms map, properties, :cspace_term, :cspace_label
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

          CollectionSpace::XML.add xml, 'shortIdentifier', Utils::Identifiers.short_identifier(self.material_name)
          CollectionSpace::XML.add xml, 'description', self.description

          materialTermGroup = [{
            'termDisplayName' => self.material_name,
            # 'termName'        => self.material_name,
            'termStatus'      => self.publish == 'Published' ? 'accepted' : 'under review',
            'termPrefForLang' => 'false',
            'termType'        => 'descriptor',
            'termFlag'        => Utils::URN.generate(
              Nrb.config.domain,
              "vocabularies",
              "materialtermflag",
              'commercial',
              'commercial'
            ),
          }]
          materialTermGroup << {
            'termDisplayName' => self.generic_name,
            # 'termName'        => self.generic_name,
            'termStatus'      => self.publish == 'Published' ? 'accepted' : 'under review',
            'termPrefForLang' => 'false',
            'termType'        => 'alternate descriptor',
            'termFlag'        => Utils::URN.generate(
              Nrb.config.domain,
              "vocabularies",
              "materialtermflag",
              'common',
              'common'
            ),
          } if self.generic_name

          CollectionSpace::XML.add_group xml, 'materialTerm', materialTermGroup

          # PRODUCTION ORGANIZATION
          CollectionSpace::XML.add_group xml, 'materialProductionOrganization', [{
            'materialProductionOrganization' => Utils::URN.generate(
              Nrb.config.domain,
              "orgauthorities",
              "organization",
              Utils::Identifiers.short_identifier(self.vendor.vendor_name),
              self.vendor.vendor_name
            ),
            'materialProductionOrganizationRole' => Utils::URN.generate(
              Nrb.config.domain,
              "vocabularies",
              "materialproductionrole",
              'manufacturer',
              'manufacturer'
            ),
          }]

          # COMMON FORMS
          common_form = self.common_forms[0]
          CollectionSpace::XML.add xml, 'commonForm', Utils::URN.generate(
            Nrb.config.domain,
            "vocabularies",
            "materialform",
            common_form[0],
            common_form[1]
          ) if common_form

          # FORM TYPES
          types = self.form_types
          CollectionSpace::XML.add_group xml, 'formType', types.map { |type|
            {
              'formType' => Utils::URN.generate(
                Nrb.config.domain,
                "vocabularies",
                "materialformtype",
                type[0],
                type[1]
              ),
            }
          } if types.any?

          # COMPOSITIONS
          self.material_compositions.each do |composition|
            family_name, class_name = composition.composition_name.split("-", 2)
            CollectionSpace::XML.add_group xml, 'materialComposition', [{
              'materialCompositionFamilyName' => Utils::URN.generate(
                Nrb.config.domain,
                "conceptauthorities",
                "materialclassification",
                Utils::Identifiers.short_identifier(family_name),
                family_name
              ),
              'materialCompositionClassName'  => Utils::URN.generate(
                Nrb.config.domain,
                "conceptauthorities",
                "materialclassification",
                Utils::Identifiers.short_identifier(class_name),
                class_name
              ),
            }]
          end

          # TYPICAL USES
          typical_use = self.material_properties.find { |mp| mp.property_name == "Erosion-Control" }
          CollectionSpace::XML.add_repeat xml, "typicalUses", [{
            "typicalUse" => Utils::URN.generate(
              Nrb.config.domain,
              "vocabularies",
              "materialuse",
              "erosion_control",
              "erosion control"
            ),
          }] if typical_use

          # PROCESSES
          Material.material_process_types.each do |process_type|
            processes = self.processes_by_type process_type
            CollectionSpace::XML.add_repeat xml, "#{process_type}Processes", processes.map { |process|
              {
                "#{process_type}Process" => Utils::URN.generate(
                  Nrb.config.domain,
                  "vocabularies",
                  "#{process_type}processes",
                  process[0],
                  process[1]
                )
              }
            } if processes.any?
          end

          # PROCESS GROUPS -- additional is the exception
          processes = self.processes_by_type 'additional'
          CollectionSpace::XML.add_group xml, "additionalProcess", processes.map { |process|
            {
              "additionalProcess" => Utils::URN.generate(
                Nrb.config.domain,
                "vocabularies",
                "additionalprocesses",
                process[0],
                process[1]
              )
            }
          } if processes.any?

          # PROPERTIES
          Material.material_property_types.each do |property_type|
            properties = self.properties_by_type property_type
            CollectionSpace::XML.add_group xml, "#{property_type}Property", properties.map { |property|
              {
                "#{property_type}PropertyType" => Utils::URN.generate(
                  Nrb.config.domain,
                  "vocabularies",
                  "#{property_type}properties",
                  property[0],
                  property[1]
                )
              }
            } if properties.any?
          end

          # LIFECYCLE COMPONENTS
          components = self.lifecycle_components
          CollectionSpace::XML.add_group xml, "lifecycleComponent", components.map { |component|
            {
              "lifecycleComponent" => Utils::URN.generate(
                Nrb.config.domain,
                "vocabularies",
                "lifecyclecomponents",
                component[0],
                component[1]
              )
            }
          } if components.any?

          # EXTERNAL URL
          CollectionSpace::XML.add_group xml, 'externalUrl', [{
            'externalUrl'     => self.vendor.website,
            'externalUrlNote' => self.vendor.vendor_name,
          }]
        end
      }
    end
    builder.to_xml
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

  def add_terms(map, original_terms, map_id, map_ref)
    mapped_terms = []
    original_terms.each { |t|
      map.each { |m| mapped_terms << [ m.send(map_id), m.send(map_ref) ] if m.send(map_id) and m.gsd_term == t }
    }
    mapped_terms
  end
end
