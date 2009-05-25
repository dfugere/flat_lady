module FlatLady
  module ImportedRessource

    def self.included(model)
      model.extend ClassMethods
      model.send(:include, InstanceMethods)

      model.class_eval do
        cattr_accessor :mapping_validations
        mapping_validations = {}
        has_many :duplicate_links, :foreign_key => :import_id, :conditions => "duplicate_links.import_type = 'ImportedCompany' AND (wrong is null or wrong = false)"
        has_many :duplicates, :class_name => "Company", :through => :duplicate_links, :source => :company 
        
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

        def self.statuses
          state_machines[:import_status].states.map( &:name ).map(&:to_s)   
        end
        statuses.each do |status|
          named_scope status, :conditions => {:import_status => status}
        end
        
        
      end
    end

    module InstanceMethods
      def find_duplicates
        # for duplicate in possible_duplicates
        #           # if dup_company.shipments.size > 0
        #           DuplicateLink.create(:import => self, :existing_object => duplicate)
        #           # end
        #         end
        #         self.update_attribute(:duplicated_import, true) unless duplicate_links.empty?
        raise "must implement find_duplicates"
      end

      def remove_from_duplicates
        self.update_attribute(:duplicated_import, !duplicate_links.empty?) 
      end

      def check_integrity
        # update_attribute(:invalid_import, !valid?)
        #         find_duplicates
        raise "must implement check_integrity"
      end
      
      def push!
        raise "must implement push!"
      end
    end

    module ClassMethods
      def validates_mapping_of(*args)
         self.mapping_validations =  args
         self.validates_presence_of *args
       end

       def delete_duplicated
         delete_all(:duplicate => true)
       end

       def process!
         pending.each( &:process!)
       end

       def import!
         find(:all).each( &:import!)
       end

       def find_duplicates
         all.each(&:find_duplicates)
       end
      
    end

  end
end
