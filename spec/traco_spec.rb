# encoding: utf-8

require "spec_helper_models"
require "traco"

RSpec.describe Traco, ".split_localized_column" do
  subject { described_class }

  it "returns attribute and locale" do
    expect(subject.split_localized_column("title_sv")).to eq [ :title, :sv ]
  end

  it "handles normalized locales" do
    expect(subject.split_localized_column("title_pt_br")).to eq [ :title, :"pt-BR" ]
  end

  it "returns nil if column is not localized" do
    expect(subject.split_localized_column("title")).to be_nil
  end

  it "returns nil if column is not localized but with undercores" do
    expect(subject.split_localized_column("long_title")).to be_nil
  end
end

RSpec.describe ActiveRecord::Base, ".translates" do
  it "is available" do
    expect(Post).to respond_to :translates
  end

  it "adds functionality" do
    expect(Post.new).not_to respond_to :title
    Post.translates :title
    expect(Post.new).to respond_to :title
  end

  it "can be run more than once" do
    expect(Post.new).not_to respond_to :title, :body
    Post.translates :title
    Post.translates :body
    expect(Post.new).to respond_to :title, :body
  end

  it "allows to define several attributes at once" do
    expect(Post.new).not_to respond_to :title, :body
    Post.translates :title, :body
    expect(Post.new).to respond_to :title, :body
  end

  it "inherits columns from the superclass" do
    Post.translates :title
    SubPost.translates :body
    expect(SubPost.new).to respond_to :title, :body
    expect(Post.new).to respond_to :title
    expect(Post.new).not_to respond_to :body
  end
end

RSpec.describe Post, ".translatable_attributes" do
  before do
    Post.translates :title
  end

  it "lists the translatable attributes" do
    expect(Post.translatable_attributes).to eq [ :title ]
  end

  it "inherits attributes from superclass to a subclass" do
    SubPost.translates :body
    expect(SubPost.translatable_attributes).to eq [ :title, :body ]
  end

  it "doesn't inherit attributes from a subclass to superclass" do
    SubPost.translates :body
    expect(Post.translatable_attributes).to eq [ :title ]
  end
end

RSpec.describe Post, ".locales_for_attribute" do
  before do
    Post.translates :title
    I18n.default_locale = :"pt-BR"
    I18n.locale = :en
  end

  it "lists the locales for that attribute, current locale first, then default locale, and then alphabetically" do
    expect(Post.locales_for_attribute(:title)).to eq [ :en, :"pt-BR", :de, :sv ]
  end

  it "doesn't include a locale if there's no corresponding column for it" do
    I18n.available_locales += [ :ru ]

    expect(Post.locales_for_attribute(:title)).not_to include(:ru)
  end
end

RSpec.describe Post, ".locale_columns" do
  before do
    Post.translates :title
    I18n.default_locale = :"pt-BR"
    I18n.locale = :en
  end

  it "lists the columns-with-locale for that attribute, current locale first, then default locale, and then alphabetically" do
    expect(Post.locale_columns(:title)).to eq [
      :title_en, :title_pt_br, :title_de, :title_sv,
    ]
  end

  it "doesn't include a column-with-locale if it doesn't exist" do
    I18n.available_locales += [ :ru ]

    expect(Post.locale_columns(:title)).not_to include(:title_ru)
  end

it "supports multiple attributes" do
  Post.translates :body

    expect(Post.locale_columns(:body, :title)).to eq [
      :body_en, :body_pt_br, :body_de, :body_sv,
      :title_en, :title_pt_br, :title_de, :title_sv,
    ]
  end
end

RSpec.describe Post, ".current_locale_column" do
  before do
    Post.translates :title
  end

  it "returns the column name for the current locale" do
    I18n.locale = :sv
    expect(Post.current_locale_column(:title)).to eq :title_sv
  end

  it "returns the column name with right format for the current locale with region identifier" do
    I18n.locale = :"pt-BR"
    expect(Post.current_locale_column(:title)).to eq :title_pt_br
  end
end

RSpec.describe Post, "#title" do
  let(:post) {
    Post.new(title_sv: "Hej", title_en: "Halloa", title_pt_br: "Olá")
  }

  before do
    Post.translates :title
    I18n.locale = :sv
    I18n.default_locale = :en
  end

  it "gives the title in the current locale" do
    expect(post.title).to eq "Hej"
  end

  it "handles dashed locales" do
    I18n.locale = :"pt-BR"
    expect(post.title_pt_br).to eq "Olá"
    expect(post.title).to eq "Olá"
  end

  it "falls back to the default locale if locale has no column" do
    I18n.locale = :ru
    expect(post.title).to eq "Halloa"
  end

  it "falls back to the default locale if blank" do
    post.title_sv = " "
    expect(post.title).to eq "Halloa"
  end

  it "does not fall back to any other locale if default locale is blank" do
    post.title_sv = " "
    post.title_en = ""
    expect(post.title).to be_nil
  end

  it "does not fall back if called with fallback: false" do
    I18n.locale = :sv
    post.title_sv = ""
    expect(post.title(fallback: false)).to be_nil
  end

  # Had a bug: https://github.com/barsoom/traco/issues/25
  it "does not incorrectly memoize fallback state" do
    I18n.locale = :sv
    post.title_sv = ""
    expect(post.title(fallback: :any)).not_to be_nil
    expect(post.title(fallback: false)).to be_nil
  end

  it "returns nil if all are blank" do
    post.title_sv = " "
    post.title_en = ""
    post.title_pt_br = nil
    expect(post.title).to be_nil
  end

  it "is overridable" do
    class Post
      def title
        super.reverse
      end
    end

    expect(post.title).to eq "jeH"
  end

  # Had a regression.
  it "handles multiple columns" do
    Post.translates :title, :body
    post.title_sv = "title"
    post.body_sv = "body"
    expect(post.title).to eq "title"
    expect(post.body).to eq "body"
  end

  it "reflects locale change" do
    expect(post.title).to eq "Hej"
    I18n.locale = :en
    expect(post.title).to eq "Halloa"
    I18n.locale = :sv
    expect(post.title).to eq "Hej"
  end

  context "when the translation was defined with fallback: false" do
    let(:post) {
      Post.new(title_sv: "Hej", title_en: "Halloa")
    }

    before do
      Post.translates :title, fallback: false
      I18n.default_locale = :en
    end

    it "does not fall back to the default locale if locale has no column" do
      I18n.locale = :ru
      expect(post.title).to be_nil
    end

    it "does not fall back to the default locale if blank" do
      I18n.locale = :sv
      post.title_sv = " "
      expect(post.title).to be_nil
    end

    it "still falls back if called with fallback: :default" do
      I18n.locale = :ru
      expect(post.title(fallback: :default)).to eq "Halloa"
    end
  end

  context "when the translation was defined with fallback: :any" do
    before do
      Post.translates :title, fallback: :any
      I18n.default_locale = :en
      I18n.locale = :"pt-BR"
    end

    it "falls back to any locale, not just the default" do
      post = Post.new(title_en: "", title_pt_br: "", title_sv: "Hej")
      expect(post.title).to eq "Hej"
    end

    it "prefers the default locale" do
      post = Post.new(title_en: "Hello", title_pt_br: "", title_sv: "Hej")
      expect(post.title).to eq "Hello"
    end
  end
end

RSpec.describe Post, "#title=" do
  before do
    Post.translates :title
  end

  let(:post) { Post.new }

  it "assigns in the current locale" do
    I18n.locale = :sv
    post.title = "Hej"
    expect(post.title_sv).to eq "Hej"
  end

  it "handles dashed locales" do
    I18n.locale = :"pt-BR"
    post.title = "Olá"
    expect(post.title_pt_br).to eq "Olá"
  end

  it "raises if locale has no column" do
    I18n.locale = :ru
    expect {
      post.title = "Privet"
    }.to raise_error(NoMethodError, /title_ru/)
  end
end

RSpec.describe Post, "#title?" do
  before do
    Post.translates :title
    I18n.locale = :sv
    I18n.default_locale = :en
  end

  it "is true if the title is present" do
    post = Post.new(title_sv: "", title_en: " ", title_pt_br: nil)
    expect(post.title?).to be false

    post.title_en = "Hello"

    expect(post.title?).to be true
  end
end

RSpec.describe Post, ".human_attribute_name" do
  before do
    Post.translates :title
    I18n.locale = :sv
  end

  it "uses explicit translations if present" do
    expect(Post.human_attribute_name(:title_sv)).to eq "Svensk titel"
  end

  it "appends translated language name if present" do
    expect(Post.human_attribute_name(:title_en)).to eq "Titel (engelska)"
  end

  it "appends an abbreviation when language name is not translated" do
    expect(Post.human_attribute_name(:title_pt_br)).to eq "Titel (PT-BR)"
  end

  it "passes through the default behavior for untranslated attributes" do
    expect(Post.human_attribute_name(:title)).to eq "Titel"
  end

  it "passes through untranslated attributes even if the name suggests it's translated" do
    expect(Post.human_attribute_name(:body_sv)).to eq "Body sv"
  end

  # ActiveModel::Errors#full_messages passes in an ugly default.

  it "does not honor passed-in defaults for locale columns" do
    expect(Post.human_attribute_name(:title_en, default: "Title en")).to eq "Titel (engelska)"
  end

  it "passes through defaults" do
    expect(Post.human_attribute_name(:body_sv, default: "Boday")).to eq "Boday"
  end
end
