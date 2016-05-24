module CollectionSpace

  class XML

    def self.add(xml, key, value)
      xml.send(key.to_sym, value)
    end

    def self.add_group(xml, key, elements = {})
      xml.send("#{key}GroupList".to_sym) {
        xml.send("#{key}Group".to_sym) {
          elements.each { |k, v| xml.send(k.to_sym, v) }
        }
      }
    end

    def self.add_lifecycle_components_group(xml, lifecycle_components = [])
      self.add_vocab_group xml, "lifecyclecomponents", "lifecycleComponent", lifecycle_components
    end

    def self.add_processes(xml, key, processes = [])
      self.add_vocab xml, "#{key}Processes", "#{key}Process", processes
    end

    def self.add_processes_group(xml, key, processes = [])
      self.add_vocab_group xml, "#{key}processes", "#{key}Process", processes, false
    end

    def self.add_properties_group(xml, key, properties = [])
      self.add_vocab_group xml, "#{key}properties", "#{key}Property", properties, true
    end

    def self.add_vocab(xml, vocab, key, elements)
      if elements.any?
        elements.each do |element|
          xml.send("#{vocab}".to_sym) {
            xml.send("#{key}".to_sym, Utils::URN.generate(
              Nrb.config.domain,
              "vocabularies",
              vocab.downcase,
              element[0],
              element[1]
            ))
          }
        end
      end
    end

    def self.add_vocab_group(xml, vocab, key, elements = [], add_type = false)
      if elements.any?
        xml.send("#{key}GroupList".to_sym) {
          elements.each do |element|
            xml.send("#{key}Group".to_sym) {
              e = add_type ? "#{key}Type" : key
              xml.send("#{e}".to_sym, Utils::URN.generate(
                Nrb.config.domain,
                "vocabularies",
                vocab.downcase,
                element[0],
                element[1]
              ))
            }
          end
        }        
      end
    end

  end

end