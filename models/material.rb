class Material < ActiveRecord::Base
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
