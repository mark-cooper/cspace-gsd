require File.join(__dir__, 'config/boot')

StandaloneMigrations::Tasks.load_tasks

require 'csv'

namespace :csv do

  # rake csv:seed[material,db/data/materials.csv]
  # rake csv:seed[material_form,db/data/material2form.csv]
  # rake csv:seed[material_process,db/data/material2process.csv]
  # rake csv:seed[material_property,db/data/material2property.csv]
  desc "Seed model data from CSV"
  task :seed, [:model, :csv] => :environment do |t, args|
    model = Kernel.const_get args[:model].downcase.camelize
    csv   = args[:csv]

    csv_row_counter = 0
    model_row_count = 0

    model.send :delete_all
    raise 'CSV file not found!' unless File.file? csv
    CSV.foreach(csv, {
        headers: true,
        header_converters: ->(header) { header.to_sym },
      }) do |row|
        data = row.to_hash
        model.send(:create!, data)
        csv_row_counter += 1
    end

    model_row_count = model.send :count

    # confirm row count matches model count
    puts "\n~~~~~ CSV SEEDING COMPLETE ~~~~~"
    puts "CSV rows read:\t#{csv_row_counter}"
    puts "#{model.to_s} records imported:\t#{model_row_count.to_s}"
  end
end
