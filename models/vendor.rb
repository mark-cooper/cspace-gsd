class Vendor < ActiveRecord::Base
  has_many :materials, primary_key: :vendor_id, foreign_key: :vendor_id

  def to_cspace_xml
    #
  end
end
