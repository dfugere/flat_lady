DEFAULT_ATTRIBUTES = %W(invalid_import duplicated_import)
class ImportScaffoldGenerator < Rails::Generator::NamedBase
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_singular_name,
                :controller_plural_name,
                :resource_edit_path,
                :base_name,
                :initial_name,
                :default_file_extension,
                :generator_default_file_extension
  alias_method  :controller_file_name,  :controller_singular_name
  alias_method  :controller_table_name, :controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    super
    @controller_name = "flat_lady/#{@name.pluralize}"

    @base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @initial_name = @base_name.dup
    @controller_class_name_without_nesting, @controller_singular_name, @controller_plural_name = inflect_names(@base_name)

    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions(controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}Helper")
      m.class_collisions(class_path, "#{class_name}")

      # Controller, helper, views, and test directories.
      m.directory(File.join('app/models', class_path))
      m.directory(File.join('app/controllers', controller_class_path))
      m.directory(File.join('app/helpers', controller_class_path))
      m.directory(File.join('app/views', controller_class_path, controller_file_name))

      # m.directory(File.join('test/functional', controller_class_path))
      m.directory(File.join('test/unit', class_path))
      
      scaffold_views.each do |action|
        m.template(
          "view_#{action}.haml",
          File.join('app/views', controller_class_path, controller_file_name, "#{action}.html.haml")
        )
      end

      m.template('model.rb', File.join('app/models', class_path, "#{file_name}.rb"))
      m.template('controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb"))
      m.template('helper.rb',          File.join('app/helpers',     controller_class_path, "#{controller_file_name}_helper.rb"))


      # m.template("functional_test.rb", File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
      m.template('unit_test.rb',       File.join('test/unit',       class_path, "#{file_name}_test.rb"))
      # m.template('fixtures.yml',       File.join('test/fixtures',   "#{table_name}.yml"))
      
      sentinel = "# --NEW FACTORY MARKER--"
      m.gsub_file('test/factories.rb', /(#{Regexp.escape(sentinel)})/mi) do |match|
        "\n\n#{generate_factory}\n\n#{match}"
      end
      sentinel = "# --NEW MAPPING MARKER--"
      m.gsub_file('config/import_mapping.yml', /(#{Regexp.escape(sentinel)})/mi) do |match|
        "\n\n#{generate_mapping}\n\n#{match}"
      end
 

      unless options[:skip_migration]
        
        m.migration_template(
          'migration.rb', 'db/migrate', 
          :assigns => {
            :migration_name => "Create#{class_name.camelize.pluralize.gsub(/::/, '')}",
            :attributes     => attributes
          }, 
          :migration_file_name => "create_imported_#{file_path.gsub(/\//, '_').pluralize}"
        )
      end

      m.route_resource plural_name
    end
  end
  
  protected

    def generate_factory
      attrs = attributes.collect {|a| "  f.#{a.name} #{a.default_value}"}.join("\n")
"Factory.define :#{name} do |f|
#{attrs}
end"
    end

    def generate_mapping
      attrs = attributes.collect {|a| "  #{a.name}: #{a.name.humanize}"}.join("\n")
"#{initial_name.singularize}:
#{attrs}
"
    end
 
    
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} scaffold_resource ModelName [field:type, field:type]"
    end

    def rspec_views
      %w[ index show new edit ]
    end
    
    def scaffold_views
      rspec_views + %w[ _form ]
    end

    def model_name 
       class_name.demodulize 
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--rspec", "Force rspec mode (checks for RAILS_ROOT/spec by default)") { |v| options[:rspec] = true }
    end
    
    def inflect_names(name)
      camel  = "Imported#{name.camelize}".camelize
      under  = camel.underscore
      plural = under.pluralize
      [camel, under, plural]
    end
    
    
end

Rails::Generator::Commands::Create.class_eval do


  def route_resource(resource)
    sentinel = 'ActionController::Routing::Routes.draw do |map|'

    logger.route "map.resources #{resource}"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        route = %(map.namespace( :flat_lady )do |flat_lady| 
          flat_lady.resources :#{resource}
          flat_lady.resources :import_files, :has_many => :#{resource}
        end)
        "#{match}\n  #{route}\n"
      end
    end
  end
end 
Rails::Generator::Commands::Destroy.class_eval do


  def route_resource(resource)
  end
end
module Rails
  module Generator
    class GeneratedAttribute
      def default_value
        @default_value ||= case type
          when :int, :integer               then "\"1\""
          when :float                       then "\"1.5\""
          when :decimal                     then "\"9.99\""
          when :datetime, :timestamp, :time then "Time.now"
          when :date                        then "Date.today"
          when :string                      then "\"MyString\""
          when :text                        then "\"MyText\""
          when :boolean                     then "false"
          else
            ""
        end      
      end

      def input_type
        @input_type ||= case type
          when :text                        then "textarea"
          else
            "input"
        end      
      end
    end
  end
end
