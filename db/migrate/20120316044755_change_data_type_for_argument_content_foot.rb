class ChangeDataTypeForArgumentContentFoot < ActiveRecord::Migration
  def self.up
      change_table :arguments do |t|
        t.change :content_foot, :text
      end
    end

    def self.down
      change_table :arguments do |t|
        t.change :content_foot, :string
      end
    end
    
end
