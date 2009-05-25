class ProcessImportJob
  attr_accessor :import_file_id

  def initialize(import_file)
    self.import_file_id = import_file.id
  end

  def perform
    import_file = ImportFile.find(import_file_id)
    import_file.upload!  
    import_file.process!  
  end    
end