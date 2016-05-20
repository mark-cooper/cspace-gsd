Nrb.configure do |config|
  # Root of the script folder
  config.root = File.expand_path('..', __dir__)

  # Default directories to autoload_paths
  # config.autoload_paths = %w(models services)

  config.domain           = "materials.collectionspace.org"
  config.vocabularies_url = "https://raw.githubusercontent.com/mark-cooper/cspace-application/materials_updates/tomcat-main/src/main/resources/defaults/base-instance-vocabularies.xml"
end
