class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %>, :force => true do |t|
<% for attribute in (attributes) -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>
      t.boolean :duplicated_import, :default => false
      t.boolean :invalid_import, :default => false
      t.string :import_status       
      t.integer :import_file_id       
      t.timestamps
    end
    
<% for attribute in (attributes.select {|att| att.name.ends_with?("_id")}) -%>
    <%= "add_index :#{table_name}, :#{attribute.name}" %>
<% end -%>
<%= "add_index :#{table_name}, :import_file_id" %>
<%= "add_index :#{table_name}, :duplicated_import" %>
<%= "add_index :#{table_name}, :invalid_import" %>
<%= "add_index :#{table_name}, :import_status" %>

  end

  def self.down
    drop_table :<%= table_name %>
  end
end
