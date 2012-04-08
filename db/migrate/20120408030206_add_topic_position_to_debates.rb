class AddTopicPositionToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :topic, :text
    add_column :debates, :position, :boolean
  end
end
