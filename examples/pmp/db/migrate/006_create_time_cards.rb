class CreateTimeCards < ActiveRecord::Migration
  def self.up
    create_table :time_cards do |t|
    end
  end

  def self.down
    drop_table :time_cards
  end
end
