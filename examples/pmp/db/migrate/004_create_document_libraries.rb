class CreateDocumentLibraries < ActiveRecord::Migration
  def self.up
    create_table :document_libraries do |t|
    end
  end

  def self.down
    drop_table :document_libraries
  end
end
