class FlatLadyBackgroundGenerator < Rails::Generator::Base

  def manifest
    record do |m|

      unless  File.exists?('db/migrate/create_delayed_jobs.rb')
        m.migration_template( "migrations/create_delayed_jobs.rb",
                              'db/migrate',
                              :migration_file_name => "flat_lady_create_delayed_jobs")
      end
      m.readme "README"
    end
  end

 
 

end
