class Vendor < ActiveRecord::Base
  has_many :materials, primary_key: :vendor_id, foreign_key: :vendor_id

  def to_cspace_xml
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.document(name: 'organizations') {
        xml.send(
          'ns2:organizations_common',
          'xmlns:ns2' => 'http://collectionspace.org/services/organization',
          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance'
        ) do
          # applying namespace breaks import
          xml.parent.namespace = nil

          CollectionSpace::XML.add xml, 'shortIdentifier', Utils::Identifiers.short_identifier(self.vendor_name)

          CollectionSpace::XML.add_group xml, 'orgTerm', [{
            'termDisplayName' => self.vendor_name,
            'mainBodyName'    => self.vendor_name,
            'termStatus'      => 'accepted',
          }]

          CollectionSpace::XML.add_repeat xml ,'contactNames', [{
            'contactName' => Utils::URN.generate(
              Nrb.config.domain,
              "personauthorities",
              "person",
              Utils::Identifiers.short_identifier(self.contact),
              self.contact
            ),
          }] if self.contact
        end
      }
    end
    builder.to_xml
  end

end
