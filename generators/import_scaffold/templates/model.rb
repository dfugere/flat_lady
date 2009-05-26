class <%= class_name %> < ActiveRecord::Base
  ### Plugin Magic
  include FlatLady::ImportedRessource

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

  
  
  # def to_s
  #   name
  # end
  
end
