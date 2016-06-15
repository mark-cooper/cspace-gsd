module CollectionSpace

  class XML

    def self.add(xml, key, value)
      xml.send(key.to_sym, value)
    end

    def self.add_group_list(xml, key, elements = [])
      xml.send("#{key}GroupList".to_sym) {
        elements.each do |element|
          xml.send("#{key}Group".to_sym) {
            element.each { |k, v| xml.send(k.to_sym, v) }
          }
        end
      }
    end

    def self.add_list(xml, key, elements = [])
      xml.send("#{key}List".to_sym) {
        elements.each do |element|
          xml.send("#{key}".to_sym) {
            element.each { |k, v| xml.send(k.to_sym, v) }
          }
        end
      }
    end

    def self.add_repeat(xml, key, elements = [])
      xml.send(key.to_sym) {
        elements.each do |element|
          element.each { |k, v| xml.send(k.to_sym, v) }
        end
      }
    end

  end

end