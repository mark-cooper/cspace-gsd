class Material < ActiveRecord::Base
  has_many :properties, primary_key: :material_id, foreign_key: :material_id
  before_save :sanitize

  def sanitize
    { 
      strip: [],
      squeeze: ["\n"],
      gsub: [Regexp.new("(\n|\t)"), " "]
    }.each do |method, args|
      self.attributes.each { |a, v| self[a] = v.send method, *args if v.respond_to? method }
    end
  end

  def to_cspace_xml
    #
  end
end
