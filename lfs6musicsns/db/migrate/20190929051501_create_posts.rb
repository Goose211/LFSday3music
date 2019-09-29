class CreatePosts < ActiveRecord::Migration[5.2]
  def change
     create_table :posts do |t|
      t.string :artist
      t.string :album
      t.string :track
      t.string :image
      t.string :sampleurl
      t.text :comment
      t.string :crossroads
      t.integer :user_id
      t.string :user_name
      t.timestamps null: false
    end
  end
end
