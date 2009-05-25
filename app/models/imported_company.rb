class ImportedCompany < ActiveRecord::Base
  ### Plugin Magic
  
  ### Associations
  has_many :duplicate_links, :foreign_key => :import_id, :conditions => "duplicate_links.import_type = 'ImportedCompany' AND (wrong is null or wrong = false)"
  has_many :duplicates, :class_name => "Company", :through => :duplicate_links, :source => :company 
 
  ### Validations
  ### Named scopes
  
  ### Callbacks
  
  ### Details  
  cattr_accessor :mapping_validations
  class << self
    def validates_mapping_of(*args)
      self.mapping_validations =  args
      self.validates_presence_of *args
    end

    def delete_duplicated
      delete_all(:duplicate => true)
    end
    
    def process!
       each( &:process!)
    end
    
    def import!
       all.each( &:import!)
    end
    
    def find_duplicates
      all.each(&:find_duplicates)
    end
  end
  
  
  validates_mapping_of :name
  
  
  def to_s 
    name
  end
  
  def find_duplicates
    @dup_companies =  (Company.where(["name like ?", name]).find(:all) rescue [])
    for dup_company in @dup_companies
      # if dup_company.shipments.size > 0
      DuplicateLink.create(:import => self, :existing_object => dup_company)
      # end
    end
    self.update_attribute(:duplicate, true) unless duplicate_links.empty?
  end

  def remove_from_duplicates
    self.update_attribute(:duplicate, !duplicate_links.empty?) 
  end
  
  
  def check_integrity
    update_attribute(:invalid, !valid?)
    find_duplicates
  end
  def push!
     Company.create!(
        Company.columns.inject({}) do |h,column|
          h[column.name] = send(column.name)
          h
        end
      )
  end
  
  ### State machine
  state_machine :status, :initial => :pending do
    before_transition all => :processed, :do => :check_integrity
    before_transition all => :imported, :do => :push!
  
    event :process do
      transition [:pending] => :processed
    end
  
    event :import do
      transition [:processed] => :imported
    end
  end
  
  def self.statuses
    state_machines[:status].states.map( &:name ).map(&:to_s)   
  end
  statuses.each do |status|
    named_scope status, :conditions => {:status => status}
  end
  
  
  # def to_s
  #   name
  # end
  
end
