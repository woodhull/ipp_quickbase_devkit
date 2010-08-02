class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
    end
  end

  def self.down
    drop_table :tasks
  end
end
