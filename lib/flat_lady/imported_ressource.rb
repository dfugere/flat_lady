module FlatLady
  module ImportedRessource

    def self.included(model)
      model.extend ClassMethods
      model.send(:include, InstanceMethods)

      model.class_eval do
        cattr_accessor :mapping_validations
        mapping_validations = {}
             
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
        
        
      end
    end

    module InstanceMethods
 

      def remove_from_duplicates
        self.update_attribute(:duplicated_import, !duplicate_links.empty?) 
      end

      def check_integrity
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
         all.each( &:process!)
       end

       def import!
         all.each( &:import!)
       end

       def find_duplicates
         all.each(&:find_duplicates)
       end
      
    end

  end
end
