class ChangeArgumentTable < ActiveRecord::Migration
  def change
    change_table :arguments do |t|   
        t.change :content_foot, :text, :limit => nil
    end
  end
end
