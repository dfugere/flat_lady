class ImportedCompaniesController < ResourceController::Base
  layout "import"
  searchable_resource
  before_filter :reset_collection_index, :only => [:show, :edit]
  belongs_to :import_file
  # before_filter :require_user
  # access_control :DEFAULT => 'admin'
  
  destroy.wants.js do
    render :update do |page|
      page.remove dom_id(@imported_company)
    end
  end   
  
  def index
    search.per_page = nil
    @imported_companies, @imported_companies_count = search.all, search.count
  end
    
    
  def delete_duplicated
    (parent_object || end_of_association_chain).delete_duplicated
    flash[:notice] = "All duplicates have been deleted"
    redirect_to :back
  end  
  def filter
    (parent_object).process!
    flash[:notice] = "Searching for duplicates"
    redirect_to :back
  end
  def push
    # (parent_object || end_of_association_chain).import!
    @import_file = parent_object
    if @import_file
      @import_file.start_import!
      Delayed::Job.enqueue( ImportJob.new(@import_file))
    end    
    flash[:notice] = "Imported companies"
    redirect_to :back
  end
end
