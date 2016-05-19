class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.integer  :vendor_id, index: true, null: false
      t.string   :vendor_name
      t.string   :website
      t.string   :street_address
      t.string   :city
      t.string   :state
      t.string   :postal_code
      t.string   :country
      t.string   :phone
      t.string   :fax
      t.string   :email
      t.string   :contact
      t.datetime :dtime
    end
  end
end
