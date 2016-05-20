class Material < ActiveRecord::Base
  has_many :material_compositions, primary_key: :material_id, foreign_key: :material_id
  has_many :material_forms,        primary_key: :material_id, foreign_key: :material_id
  has_many :material_processes,    primary_key: :material_id, foreign_key: :material_id
  has_many :material_properties,   primary_key: :material_id, foreign_key: :material_id

  belongs_to :vendor, primary_key: :vendor_id, foreign_key: :vendor_id

  before_save :sanitize

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
