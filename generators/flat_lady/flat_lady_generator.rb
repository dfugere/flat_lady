require File.expand_path(File.dirname(__FILE__) + "/lib/insert_commands.rb")
require File.expand_path(File.dirname(__FILE__) + "/lib/rake_commands.rb")
require 'factory_girl'

class FlatLadyGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.directory File.join("test", "factories")
      m.file "factories.rb", "test/factories/flat_lady.rb"
      m.directory File.join("config")
      m.file "import_mapping.yml", "config/import_mapping.yml"
      m.file "import.css", "public/stylesheets/import.css"
      unless  File.exists?('db/migrate/create_import_files.rb')
        m.migration_template( "migrations/create_import_files.rb",
                             'db/migrate',
                             :migration_file_name => "flat_lady_create_import_files")
      end

      m.readme "README"
    end
  end

 
 

end
