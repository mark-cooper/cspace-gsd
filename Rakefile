require File.join(__dir__, 'config/boot')

StandaloneMigrations::Tasks.load_tasks

require 'csv'

namespace :csv do

  # rake csv:seed[material,db/data/materials.csv]
  desc "Seed model data from CSV"
  task :seed, [:model, :csv] => :environment do |t, args|
    model = Kernel.const_get args[:model].downcase.capitalize
    csv   = args[:csv]

    model.send :delete_all
    raise 'CSV file not found!' unless File.file? csv
    CSV.foreach(csv, {
        headers: true,
        header_converters: ->(header) { header.to_sym },
      }) do |row|
        data = row.to_hash
        model.send(:create!, data)
        break
    end
  end
end
