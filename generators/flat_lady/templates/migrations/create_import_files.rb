class FlatLadyCreateImportFiles < ActiveRecord::Migration
  def self.up
    create_table :import_files, :force => true do |t|
      t.string :data_file_name
      t.string :data_content_type
      t.string :data_file_size
      t.string :data_updated_at
      t.text :mapping
      t.string :name
      t.string :status
      t.integer :user_id
      t.string :target_model

      t.timestamps
    end
    
    add_index :import_files, :user_id
    add_index :import_files, :target_model 
  end

  def self.down
    drop_table :import_files
  end
end
