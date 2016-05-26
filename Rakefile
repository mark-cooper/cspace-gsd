require File.join(__dir__, 'config/boot')

StandaloneMigrations::Tasks.load_tasks

require 'csv'

namespace :csv do

  desc "Seed model data from CSV"
  task :seed, [:model, :csv] => :environment do |t, args|
    model = Kernel.const_get args[:model].downcase.camelize
    csv   = args[:csv]

    csv_row_counter = 0
    model_row_count = 0
    errors          = []

    model.send :delete_all
    raise 'CSV file not found!' unless File.file? csv
    CSV.foreach(csv, {
        headers: true,
        header_converters: ->(header) { header.to_sym },
      }) do |row|
        data = row.to_hash
        begin
          model.send(:create!, data)
        rescue Exception => ex
          errors << "#{ex.message} for #{data}"
        end
        csv_row_counter += 1
    end

    model_row_count = model.send :count

    # confirm row count matches model count
    puts "\n~~~~~ CSV SEEDING COMPLETE ~~~~~"
    puts "CSV rows read:\t#{csv_row_counter}"
    puts "#{model.to_s} records imported:\t#{model_row_count.to_s}"
    ap errors if errors.any?
  end
end

namespace :export do

  # rake export:all[material]
  desc "Export all records for a model"
  task :all, [:model, :field] => :environment do |t, args|
    model = args[:model]

    exports_directory = "exports/#{model}"
    FileUtils.mkdir_p exports_directory

    field = (args[:field] || "#{model}_id").to_sym
    model = Kernel.const_get model.downcase.camelize

    model_export_count = 0
    errors             = []

    model.send(:all).each do |record|
      begin
        id = record.send(field)
        File.open("#{exports_directory}/#{id}.xml", 'w') { |f| f.write record.to_cspace_xml }
        model_export_count += 1
      rescue Exception => ex
        errors << "Export failed for #{model.to_s} #{field.to_s} #{id}:\t#{ex.message}"
      end
    end

    puts "\n~~~~~ EXPORT COMPLETE ~~~~~"
    puts "#{model.to_s} records read:\t#{model.send(:count).to_s}"
    puts "#{model.to_s} records exported:\t#{model_export_count.to_s}"
    ap errors if errors.any?
  end

  # rake export:record[material,17]
  desc "Export a single record by model and id"
  task :record, [:model, :id, :field] => :environment do |t, args|
    model = args[:model]

    exports_directory = "exports/#{model}"
    FileUtils.mkdir_p exports_directory

    id    = args[:id].to_i
    field = (args[:field] || "#{model}_id").to_sym
    model = Kernel.const_get model.downcase.camelize

    record =  model.send(:where, field => id).first
    if record
      export_path = "#{exports_directory}/#{record.send(field)}.xml"
      File.open(export_path, 'w') { |f| f.write record.to_cspace_xml }
      ap "Exported record for #{model.to_s} with #{field.to_s} #{id.to_s} to #{export_path}"
    else
      ap "Unable to find record for #{model.to_s} with #{field.to_s} #{id.to_s}"
    end
  end

  # rake export:concept_hierarchy
  task :concept_hierarchy => :environment do |t|
    exports_directory = "exports/concept"
    FileUtils.mkdir_p exports_directory

    CSV.open("#{exports_directory}/concept_hierarchy.csv",'w',
        :write_headers=> true,
        :headers => [
          "from",
          "to",
        ]
      ) do |csv|
      Concept.all.each do |concept|
        next if concept.broader_concept.nil?
        csv << {
          "from" => concept.display_name,
          "to" => concept.broader_concept,
        }
      end
    end

    puts "\n~~~~~ CONCEPT HIERARCHY EXPORTED ~~~~~"
  end

  # rake export:vendor_contacts
  task :vendor_contacts => :environment do |t|
    exports_directory = "exports/vendor"
    FileUtils.mkdir_p exports_directory

    CSV.open("#{exports_directory}/vendor_contacts.csv",'w',
        :write_headers=> true,
        :headers => [
          "email",
          "webAddress",
          "telephoneNumber",
          "faxNumber",
          "addressType",
          "addressPlace1",
          "addressMunicipality",
          "addressStateOrProvince",
          "addressPostCode",
          "termDisplayName",
        ]
      ) do |csv|
      Vendor.all.each do |vendor|
        next if vendor.vendor_name.nil?
        csv << {
          "email" => vendor.email,
          "webAddress" => vendor.website,
          "telephoneNumber" => vendor.phone,
          "faxNumber" => vendor.fax,
          "addressType" => "business",
          "addressPlace1" => vendor.street_address,
          "addressMunicipality" => vendor.city,
          "addressStateOrProvince" => vendor.state,
          "addressPostCode" => vendor.postal_code,
          "termDisplayName" => vendor.vendor_name,
        }
      end
    end

    puts "\n~~~~~ VENDOR CONTACTS EXPORTED ~~~~~"
  end

  # rake export:vendor_persons
  task :vendor_persons => :environment do |t|
    exports_directory = "exports/vendor"
    FileUtils.mkdir_p exports_directory

    CSV.open("#{exports_directory}/vendor_persons.csv",'w',
        :write_headers=> true,
        :headers => [
          "termDisplayName",
        ]
      ) do |csv|
      Vendor.all.each do |vendor|
        next if vendor.contact.nil?
        csv << {
          "termDisplayName" => vendor.contact,
        }
      end
    end

    puts "\n~~~~~ VENDOR PERSONS EXPORTED ~~~~~"
  end

end