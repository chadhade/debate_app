class CreateDebaters < ActiveRecord::Migration
  def change
    create_table :debaters do |t|
      t.string :name
      t.string :encrypted_password

      t.timestamps
    end
  end
end
