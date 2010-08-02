class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
    end
  end

  def self.down
    drop_table :contacts
  end
end
