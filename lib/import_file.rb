class ImportFile < ActiveRecord::Base

  ### Plugin Magic
  has_attached_file :data, :path => ":rails_root/public/:attachment/:id/:style/:basename.:extension"
  
  ### Associations
  belongs_to :user

  ### Validations
  validates_presence_of :name, :target_model
  
  ### Named scopes
  
  ### Callbacks
  
  ### Details
  # def to_s
  #   name
  # end
  serialize :mapping
  
  ### Associations
  belongs_to :user
  ### Validations
  
  ### Named scopes
  
  ### Callbacks
  
  ### Details
  # def to_s
  #   name
  # end
 
  def validate
    buffer_class.mapping_validations.each do |arg|
      errors.add_to_base("#{model_mapping[arg.to_s]} must be specified")  if  mapping && !mapping.values.include?(arg.to_s)
    end if buffer_class.mapping_validations
  end
  
  def valid_encoding?
    content.is_utf8?
  end
  

  class << self
    def target_models
      @target_models ||= IMPORT_MAPPING.keys
    end
    def buffer_models
      @buffer_models ||= IMPORT_MAPPING.keys.map{|model| "imported_#{model}"}
    end
    def import_mapping
      (YAML::load(File.open("#{RAILS_ROOT}/config/import_mapping.yml")) rescue {})
    end
    def target_models
      import_mapping.keys rescue []
    end
    def buffer_models
      target_models.map{|model| "imported_#{model}"}
    end
    def pluralized_buffer_models
      buffer_models.map(&:pluralize)
    end
    
  end
  # declare has_many for every possible imported model
  # ex. : has_many "imported_copmanies" ...
  for association in pluralized_buffer_models
    has_many association, :dependent => :destroy
  end

  def model_mapping
    ImportFile.import_mapping[target_model]
  end
  

  def content
   @content ||= File.read(data.path)
  end
  def utf8_data
    @utf8_data ||= Iconv.new('utf-8', 'MacRoman').iconv(content)
  end

  def table
    @table ||= FasterCSV.parse( utf8_data, 
                            { :headers           => true,
                              :converters        => :numeric } )
  end

    def upload!
      values = table.collect{|row|
        fields.collect{|key, value|
          logger.info value
          case value
          when :import_file_id : id
          when :import_status : "pending"
          else
            row.field(value)
          end
        }
      }
      imported_objects.delete_all
      @imported = buffer_class.import(fields.keys, values, :validate => false) unless values.empty?
      end_upload!
      logger.info("END UPLOAD")
    end
    
    def find_duplicates
      imported_objects.find_duplicates
    end
    
    def imported_objects
      send(imports_name)
    end
    
    def imports_name
      buffer_model.pluralize 
    end
    
    def fields
      unless @fields
        @fields = mapping.inject({}){|hash, field|
          hash[field[1]] = field[0] unless field[1].blank? 
          hash
        }
        @fields.merge!({:import_file_id => :import_file_id , :import_status => :import_status})
      end
      @fields
    rescue 
      {}
    end
    
    
    def target_class
      target_model.camelize.constantize
    end
   
    def buffer_class
      buffer_model.camelize.constantize
    end
    
    def buffer_model
      "imported_#{target_model}"
    end
   
    def humanized_mapping
      @humanized_mapping ||= columns_mapping.collect{|k, v| [v,k]}.sort  
    end
    def columns_mapping
      buffer_class.columns.inject({}){|h,column|h[column.name] = column.human_name; h}.merge(ImportFile.import_mapping[target_model] || {}).except(*private_attributes)
    end
    def delete_duplicated
      imported_objects.delete_duplicated
    end  
    
    def push!
      imported_objects.each( &:import!)
    end
    
    def import!
      push!
      end_import!
    end

    def check_integrity
      logger.info("checking integrity")
      imported_objects.each( &:process!)
    end
    
    def process!
      start_processing!
      logger.info("processing")
      check_integrity
      end_processing!
    end
    def start_upload_job
      Delayed::Job.enqueue( ProcessImportJob.new(self))
    end
    
    ### State machine
    state_machine :status, :initial => :pending do
      after_transition all => :uploading, :do => :start_upload_job
      # before_transition all=> :imported , :do => :push!
    
      event :start_upload do
        transition all => :uploading
      end
      event :end_upload do
        transition all => :uploaded
      end
      event :start_processing do
        transition all => :processing
      end
      event :end_processing do
        transition all => :processed
      end
    
      event :start_import do
        transition all => :importing
      end
      event :end_import do
        transition all => :imported
      end
    end
    
    def self.statuses
      state_machines[:status].states.map( &:name ).map(&:to_s)   
    end
    statuses.each do |status|
      named_scope status, :conditions => {:status => status}
    end
 
    
    
    private 
    
    def private_attributes
      %W(id created_at updated_at duplicate invalid  #{target_model}_id)
    end
end
