require File.join(__dir__, 'config/boot')

StandaloneMigrations::Tasks.load_tasks

require 'csv'

namespace :csv do

  # rake csv:seed[material,db/data/materials.csv]
  # rake csv:seed[material_composition,db/data/material2composition.csv]
  # rake csv:seed[material_form,db/data/material2form.csv]
  # rake csv:seed[material_process,db/data/material2process.csv]
  # rake csv:seed[material_property,db/data/material2property.csv]
  # rake csv:seed[material_map,db/material_maps.csv]
  # rake csv:seed[vendor,db/data/vendors.csv]
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
    puts "Records read:\t#{model.send(:count).to_s}"
    puts "Records exported:\t#{model_export_count.to_s}"
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

end