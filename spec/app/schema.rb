ActiveRecord::Schema.define(version: 0) do

  create_table :posts, force: true do |t|
    t.string :title_sv, :title_en, :title_fi
    t.string :body_sv, :body_en, :body_fi
  end

end
