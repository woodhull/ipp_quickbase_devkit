class CreateResources < ActiveRecord::Migration
  def self.up
    create_table :resources do |t|
    end
  end

  def self.down
    drop_table :resources
  end
end
