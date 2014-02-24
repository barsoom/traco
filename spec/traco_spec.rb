# encoding: utf-8

require "spec_helper"
require "traco"

describe ActiveRecord::Base, ".translates" do
  it "is available" do
    Post.should respond_to :translates
  end

  it "adds functionality" do
    Post.new.should_not respond_to :title
    Post.translates :title
    Post.new.should respond_to :title
  end

  it "can be run more than once" do
    Post.new.should_not respond_to :title, :body
    Post.translates :title
    Post.translates :body
    Post.new.should respond_to :title, :body
  end

  it "inherits columns from the superclass" do
    Post.translates :title
    SubPost.translates :body
    SubPost.new.should respond_to :title, :body
    Post.new.should respond_to :title
    Post.new.should_not respond_to :body
  end
end

describe Post, ".translatable_attributes" do
  before do
    Post.translates :title
  end

  it "lists the translatable attributes" do
    Post.translatable_attributes.should == [ :title ]
  end
end

describe Post, ".locales_for_attribute" do
  before do
    Post.translates :title
  end

  it "lists the locales, default first and then alphabetically" do
    I18n.default_locale = :"pt-BR"
    Post.locales_for_attribute(:title).should == [
      :pt_br, :en, :sv
    ]
  end
end

describe Post, ".locale_columns" do
  before do
    Post.translates :title
    I18n.default_locale = :"pt-BR"
  end

  it "lists the columns-with-locale for that attribute, default locale first and then alphabetically" do
    Post.locale_columns(:title).should == [
      :title_pt_br, :title_en, :title_sv
    ]
  end

  it "supports multiple attributes" do
    Post.translates :body
    Post.locale_columns(:body, :title).should == [
      :body_pt_br, :body_en, :body_sv,
      :title_pt_br, :title_en, :title_sv
    ]
  end
end

describe Post, ".current_locale_column" do
  before do
    Post.translates :title
  end

  it "returns the column name for the current locale" do
    I18n.locale = :sv
    Post.current_locale_column(:title).should == :title_sv
  end
end

describe Post, "#title" do
  let(:post) {
    Post.new(title_sv: "Hej", title_en: "Halloa", title_pt_br: "Olá")
  }

  before do
    Post.translates :title
    I18n.locale = :sv
    I18n.default_locale = :en
  end

  it "gives the title in the current locale" do
    post.title.should == "Hej"
  end

  it "handles dashed locales" do
    I18n.locale = :"pt-BR"
    post.title_pt_br.should == "Olá"
    post.title.should == "Olá"
  end

  it "falls back to the default locale if locale has no column" do
    I18n.locale = :ru
    post.title.should == "Halloa"
  end

  it "falls back to the default locale if blank" do
    post.title_sv = " "
    post.title.should == "Halloa"
  end

  it "does not fall back to any other locale if default locale is blank" do
    post.title_sv = " "
    post.title_en = ""
    post.title.should be_nil
  end

  it "does not fall back if called with fallback: false" do
    I18n.locale = :sv
    post.title_sv = ""
    post.title(fallback: false).should be_nil
  end

  it "returns nil if all are blank" do
    post.title_sv = " "
    post.title_en = ""
    post.title_pt_br = nil
    post.title.should be_nil
  end

  it "is overridable" do
    class Post
      def title
        super.reverse
      end
    end

    post.title.should == "jeH"
  end

  # Had a regression.
  it "handles multiple columns" do
    Post.translates :title, :body
    post.title_sv = "title"
    post.body_sv = "body"
    post.title.should == "title"
    post.body.should == "body"
  end

  it "reflects locale change" do
    post.title.should == "Hej"
    I18n.locale = :en
    post.title.should == "Halloa"
    I18n.locale = :sv
    post.title.should == "Hej"
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
      post.title.should be_nil
    end

    it "does not fall back to the default locale if blank" do
      I18n.locale = :sv
      post.title_sv = " "
      post.title.should be_nil
    end

    it "still falls back if called with fallback: :default" do
      I18n.locale = :ru
      post.title(fallback: :default).should == "Halloa"
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
      post.title.should == "Hej"
    end

    it "prefers the default locale" do
      post = Post.new(title_en: "Hello", title_pt_br: "", title_sv: "Hej")
      post.title.should == "Hello"
    end
  end
end

describe Post, "#title=" do
  before do
    Post.translates :title
  end

  let(:post) { Post.new }

  it "assigns in the current locale" do
    I18n.locale = :sv
    post.title = "Hej"
    post.title_sv.should == "Hej"
  end

  it "handles dashed locales" do
    I18n.locale = :"pt-BR"
    post.title = "Olá"
    post.title_pt_br.should == "Olá"
  end

  it "raises if locale has no column" do
    I18n.locale = :ru
    lambda {
      post.title = "Privet"
    }.should raise_error(NoMethodError, /title_ru/)
  end
end

describe Post, ".human_attribute_name" do
  before do
    Post.translates :title
    I18n.locale = :sv
  end

  it "uses explicit translations if present" do
    Post.human_attribute_name(:title_sv).should == "Svensk titel"
  end

  it "appends translated language name if present" do
    Post.human_attribute_name(:title_en).should == "Titel (engelska)"
  end

  it "appends an abbreviation when language name is not translated" do
    Post.human_attribute_name(:title_pt_br).should == "Titel (PT-BR)"
  end

  it "passes through the default behavior for untranslated attributes" do
    Post.human_attribute_name(:title).should == "Titel"
  end

  it "passes through untranslated attributes even if the name suggests it's translated" do
    Post.human_attribute_name(:body_sv).should == "Body sv"
  end

  # ActiveModel::Errors#full_messages passes in an ugly default.

  it "does not honor passed-in defaults for locale columns" do
    Post.human_attribute_name(:title_en, default: "Title en").should == "Titel (engelska)"
  end

  it "passes through defaults" do
    Post.human_attribute_name(:body_sv, default: "Boday").should == "Boday"
  end
end
