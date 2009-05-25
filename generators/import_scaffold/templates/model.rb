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
    self.update_attribute(:duplicated_import, !duplicate_links.empty?) 
  end
  
  def check_integrity
    update_attribute(:invalid_import, !valid?)
    find_duplicates
  end
  def push!
    company = nil
    unless name.blank?
      unless contact1_name.blank?
      # TODO: 3 elements, "," with reverse names
        first_name, last_name = contact1_name.split(" ", 2) 
        new_contact = {
          :first_name => first_name,
          :last_name => last_name,
          :title => contact1_title
        }
        contact = Contact.create(new_contact)
      end
      company = Company.find_or_create_by_name(name)
      
      address = {
        :street => address1,
        :city   => city,
        :state  => state,
        :zip    => zip 
      }
      company.addresses.create(address) unless address.values.all?(&:blank?)

      if company && contact
        Relation.create( contact => Relation::EMPLOYEE, company => Relation::EMPLOYER)
      end

      add_to = contact
      add_to ||= company

      add_to.phone_numbers.create(:value => phone) unless add_to.blank? || phone.blank?
      add_to.emails.create(:value => email) unless add_to.blank? || phone.blank?
      add_to.websites.create(:value => website ) unless add_to.blank? || phone.blank?
    end
  rescue 
  end
  
  ### State machine
  state_machine :import_status, :initial => :pending do
    before_transition all => :processed, :do => :check_integrity
    before_transition all => :imported, :do => :push!
  
    event :process do
      transition [:pending] => :processed
    end
  
    event :import do
      transition [:processed] => :imported
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
