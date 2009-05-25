require 'resource_controller'
require 'haml'
class FlatLady::ImportFilesController < ResourceController::Base
  searchable_resource
  before_filter :reset_collection_index, :only => [:show, :edit]
 
  unloadable
   
  # before_filter :require_user
  # access_control :DEFAULT => 'admin'
  # layout  "import"  
  def index
    @import_files = ImportFile.all
  end
    
  create.wants.html do
    if @import_file.reload.valid_encoding?
      redirect_to edit_flat_lady_import_file_url(object)
    else
      flash[:error] = "We were unable to determine the proper encoding for your uploaded file. Please try another file or contact Customer Service."   
      render :action => "new"
    end
  end
  update.wants.html do
    upload
  end
  def upload
    load_object
    @import_file.start_upload!
    redirect_to( eval("flat_lady_import_file_#{@import_file.imports_name}_url( @import_file)"))
  end
  
  #remove duplicates
  def clean
    load_object
    @import_file.delete_duplicated
    flash[:notice] = "All duplicates have been deleted"
    redirect_to :back
  end  
  def filter
    load_object
    @import_file.process!
    flash[:notice] = "Searching for duplicates"
    redirect_to :back
  end
  def push
    load_object
    @import_file.start_import!
    Delayed::Job.enqueue( ImportJob.new(@import_file))
    flash[:notice] = "Import has started, you will received a notification when the process will be done"
    redirect_to :back
  end
  
    
end
