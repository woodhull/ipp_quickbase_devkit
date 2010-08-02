class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
    end
  end

  def self.down
    drop_table :issues
  end
end
