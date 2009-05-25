class <%= controller_class_name %>Controller < ResourceController::Base
  layout "import"
  searchable_resource
  before_filter :reset_collection_index, :only => [:show, :edit]
  belongs_to :import_file
  # before_filter :require_user
  # access_control :DEFAULT => 'admin'
  layout  "import"
  
  def index
    #make sure all flat file in viewable at once
    search.per_page = nil
    @<%= plural_name %>, @<%= plural_name %>_count = search.all, search.count
  end
  
  #ajax deletion
  destroy.wants.js do
    render :update do |page|
      page.remove dom_id(@<%= singular_name %>)
    end
  end   
end

 
    

