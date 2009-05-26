ActionController::Routing::Routes.draw do |map|
  # map.resources( :imported_companies, 
  #    :collection => {:delete_duplicated => :any,:delete_invalid => :any,:filter => :any, :push => :any}, 
  #    :member => {:wrong_duplicate => :any})
     
  map.namespace :flat_lady do |flat_lady|
    flat_lady.resources :import_files, 
      :has_many => ImportFile.pluralized_buffer_models, 
      :member => {:upload => :any,:clean => :any, :process => :any, :push => :any}
    
  end
end
