class Concept < ActiveRecord::Base

  def to_cspace_xml
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.document(name: 'concepts') {
        xml.send(
          'ns2:concepts_common',
          'xmlns:ns2' => 'http://collectionspace.org/services/concept',
          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance'
        ) do
          # applying namespace breaks import
          xml.parent.namespace = nil

          CollectionSpace::XML.add xml, 'shortIdentifier', Utils::Identifiers.short_identifier(self.display_name)

          CollectionSpace::XML.add_group_list xml, 'conceptTerm', [{
            'termDisplayName' => self.display_name,
            'termStatus'      => 'accepted',
          }]

          CollectionSpace::XML.add_repeat xml, 'conceptRecordTypes', [{
            'conceptRecordType' => Utils::URN.generate(
              Nrb.config.domain,
              "vocabularies",
              "concepttype",
              self.record_type,
              self.record_type
            ),
          }]
        end
      }
    end
    builder.to_xml
  end

end
