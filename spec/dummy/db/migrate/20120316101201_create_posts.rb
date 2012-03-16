class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title_sv
      t.string :title_en
      t.string :title_fi
      t.text :body_sv
      t.text :body_en
      t.text :body_fi
      t.string :slug

      t.timestamps
    end
  end
end
