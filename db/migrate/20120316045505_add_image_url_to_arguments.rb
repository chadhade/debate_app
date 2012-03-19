class AddImageUrlToArguments < ActiveRecord::Migration
  def change
    add_column :arguments, :image_url, :text
  end
end
