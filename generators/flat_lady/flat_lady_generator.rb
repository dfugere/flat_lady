require File.expand_path(File.dirname(__FILE__) + "/lib/insert_commands.rb")
require File.expand_path(File.dirname(__FILE__) + "/lib/rake_commands.rb")
require 'factory_girl'

class FlatLadyGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.directory File.join("test", "factories")
      m.file "factories.rb", "test/factories/flat_lady.rb"
      m.directory File.join("config")
      m.file "import.css", "public/stylesheets/import.css"
      unless  File.exists?('db/migrate/create_import_files.rb')
        m.migration_template( "migrations/create_import_files.rb",
                             'db/migrate',
                             :migration_file_name => "flat_lady_create_import_files")
      end
      m.directory File.join("app", "controllers", "flat_lady")
      m.directory File.join("app", "models" )
      
      m.directory File.join("app", "views", "flat_lady","import_files")
      scaffold_views.each do |action|
        m.template(
          "views/flat_lady/import_files/#{action}.html.haml",
          File.join('app/views', "flat_lady", "import_files" , "#{action}.html.haml")
        )
      end
      m.file "views/layouts/import.html.haml", "app/views/layouts/import.html.haml"
      m.template('model.rb', File.join('app/models', "import_file.rb"))
      m.template('controller.rb', File.join('app/controllers', "flat_lady", "import_files_controller.rb"))
    
      m.readme "README"
    end
  end
  def rspec_views
    %w[ index show new edit ]
  end

  def scaffold_views
    rspec_views + %w[ _form ]
  end
 

end
