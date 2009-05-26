class <%= class_name %> < ActiveRecord::Base
  ### Plugin Magic
  include FlatLady::ImportedRessource
  unloadable
  ### Associations
<% for attribute in (attributes.select {|att| att.name.ends_with?("_id")}) -%>
  <%= "# belongs_to :#{attribute.name[0..-4]}" %>
<% end -%>
 
  ### Validations
  #validates_mapping_of :name
  
  
  ### Named scopes
  
  ### Callbacks
  
  ### Details  
  # def to_s 
  #   name
  # end
 

   def remove_from_duplicates
     self.update_attribute(:duplicated_import, !duplicate_links.empty?) 
   end
   def check_integrity
     raise " <%= class_name %>  must implement check_integrity"
   end
   
   def push!
     raise " <%= class_name %>  must implement push!"
      # <%= initial_name.singularize.camelize %>.create!(
      #    (<%= initial_name.singularize.camelize %>.column_names - ["id"]).inject({}) do |h, column|
      #       h[column] = send(column) if respond_to?(column)
      #       h
      #    end
      # )
   end

  ### State machine
  state_machine :import_status, :initial => :pending do
    before_transition all => :processed, :do => :check_integrity
    before_transition all => :imported, :do => :push!
  
    event :process do
      transition all => :processed
    end
  
    event :import do
      transition all => :imported
    end
  end
  
  def self.import_statuses
    state_machines[:import_status].states.map( &:name ).map(&:to_s)   
  end
  import_statuses.each do |status|
    named_scope status, :conditions => {:import_status => status}
  end
  
  
  # def to_s
  #   name
  # end
  
end
