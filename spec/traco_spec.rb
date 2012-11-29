require "spec_helper"
require "traco"

describe ActiveRecord::Base, ".translates" do
  it "should be available" do
    Post.should respond_to :translates
  end

  it "should add functionality" do
    Post.new.should_not respond_to :title
    Post.translates :title
    Post.new.should respond_to :title
  end

  it "should be possible to run more than once" do
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

describe Post, ".translatable_columns" do
  before do
    Post.translates :title
  end

  it "should list the translatable columns" do
    Post.translatable_columns.should == [ :title ]
  end
end

describe Post, ".locales_for_column" do
  before do
    Post.translates :title
  end

  it "should list the locales, default first and then alphabetically" do
    I18n.default_locale = :fi
    Post.locales_for_column(:title).should == [
      :fi, :en, :sv
    ]
  end
end

describe Post, "#title" do
  let(:post) {
    Post.new(:title_sv => "Hej", :title_en => "Halloa", :title_fi => "Moi moi")
  }

  before do
    Post.translates :title
    I18n.locale = :sv
    I18n.default_locale = :en
  end

  it "should give the title in the current locale" do
    post.title.should == "Hej"
  end

  it "should fall back to the default locale if locale has no column" do
    I18n.locale = :ru
    post.title.should == "Halloa"
  end

  it "should fall back to the default locale if blank" do
    post.title_sv = " "
    post.title.should == "Halloa"
  end

  it "should not fall back to any other locale if default locale is blank" do
    post.title_sv = " "
    post.title_en = ""
    post.title.should be_nil
  end

  it "should return nil if all are blank" do
    post.title_sv = " "
    post.title_en = ""
    post.title_fi = nil
    post.title.should be_nil
  end

  # Had a regression.
  it "handles multiple columns" do
    Post.translates :title, :body
    post.title_sv = "title"
    post.body_sv = "body"
    post.title.should == "title"
    post.body.should == "body"
  end

  context "with :fallback => false" do
    let(:post) {
      Post.new(:title_sv => "Hej", :title_en => "Halloa")
    }

    before do
      Post.translates :title, :fallback => false
      I18n.default_locale = :en
    end

    it "should not fall back to the default locale if locale has no column" do
      I18n.locale = :ru
      post.title.should be_nil
    end

    it "should not fall back to the default locale if blank" do
      I18n.locale = :sv
      post.title_sv = " "
      post.title.should be_nil
    end
  end
end

describe Post, "#title=" do
  before do
    Post.translates :title
    I18n.locale = :sv
  end

  let(:post) { Post.new }

  it "should assign in the current locale" do
    post.title = "Hej"
    post.title.should == "Hej"
    post.title_sv.should == "Hej"
  end

  it "should raise if locale has no column" do
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

  it "should append a known language name" do
    Post.human_attribute_name(:title_en).should == "Titel (engelska)"
  end

  it "should use abbreviation when language name is not known" do
    Post.human_attribute_name(:title_fi).should == "Titel (FI)"
  end

  it "should yield to defined translations" do
    Post.human_attribute_name(:title_sv).should == "Svensk titel"
  end

  it "should pass through the default behavior" do
    Post.human_attribute_name(:title).should == "Titel"
  end

  it "should pass through untranslated columns" do
    Post.human_attribute_name(:body_sv).should == "Body sv"
  end

  # ActiveModel::Errors#full_messages passes in an ugly default.

  it "should not yield to passed-in defaults" do
    Post.human_attribute_name(:title_en, :default => "Title en").should == "Titel (engelska)"
  end

  it "should pass through defaults" do
    Post.human_attribute_name(:body_sv, :default => "Boday").should == "Boday"
  end
end
