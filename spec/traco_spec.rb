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
    I18n.default_locale = :fi
    Post.locales_for_attribute(:title).should == [
      :fi, :en, :"pt-BR", :sv,
    ]
  end
end

describe Post, ".locale_columns" do
  before do
    Post.translates :title
    I18n.default_locale = :fi
  end

  it "lists the columns-with-locale for that attribute, default locale first and then alphabetically" do
    Post.locale_columns(:title).should == [
      :title_fi, :title_en, :"title_pt-BR", :title_sv
    ]
  end

  it "supports multiple attributes" do
    Post.translates :body
    Post.locale_columns(:body, :title).should == [
      :body_fi, :body_en, :"body_pt-BR", :body_sv,
      :title_fi, :title_en, :"title_pt-BR", :title_sv
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

  it "gives the title in the current locale" do
    post.title.should == "Hej"
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

  it "returns nil if all are blank" do
    post.title_sv = " "
    post.title_en = ""
    post.title_fi = nil
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

  context "with :fallback => false" do
    let(:post) {
      Post.new(:title_sv => "Hej", :title_en => "Halloa")
    }

    before do
      Post.translates :title, :fallback => false
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
  end
end

describe Post, "#title=" do
  before do
    Post.translates :title
    I18n.locale = :sv
  end

  let(:post) { Post.new }

  it "assigns in the current locale" do
    post.title = "Hej"
    post.title.should == "Hej"
    post.title_sv.should == "Hej"
  end

  it "raises if locale has no column" do
    I18n.locale = :ru
    lambda {
      post.title = "Privet"
    }.should raise_error(NoMethodError, /title_ru/)
  end

  it "can be assigned properly with special locale" do
    I18n.locale = :"pt-BR"
    expect {
      post.title = 'pt-BR'
    }.to_not raise_error
  end
end

describe Post, ".human_attribute_name" do
  before do
    Post.translates :title
    I18n.locale = :sv
  end

  it "appends a known language name" do
    Post.human_attribute_name(:title_en).should == "Titel (engelska)"
  end

  it "uses abbreviation when language name is not known" do
    Post.human_attribute_name(:title_fi).should == "Titel (FI)"
  end

  it "yields to defined translations" do
    Post.human_attribute_name(:title_sv).should == "Svensk titel"
  end

  it "passes through the default behavior" do
    Post.human_attribute_name(:title).should == "Titel"
  end

  it "passes through untranslated columns" do
    Post.human_attribute_name(:body_sv).should == "Body sv"
  end

  # ActiveModel::Errors#full_messages passes in an ugly default.

  it "does not yield to passed-in defaults" do
    Post.human_attribute_name(:title_en, :default => "Title en").should == "Titel (engelska)"
  end

  it "passes through defaults" do
    Post.human_attribute_name(:body_sv, :default => "Boday").should == "Boday"
  end
end

describe Article do
  # This record is for testing different column name format
  before do
    Traco.config.attribute_name_format = :ruby
  end

  after do
    Traco.config.attribute_name_format = nil
  end

  describe ".translatable_attributes" do
    before do
      Article.translates :title
    end

    it "lists the translatable attributes" do
      Article.translatable_attributes.should == [ :title ]
    end
  end

  describe ".locales_for_attribute" do
    before do
      Article.translates :title
    end

    it "lists the locales, default first and then alphabetically" do
      I18n.default_locale = :fi
      Article.locales_for_attribute(:title).should == [
        :fi, :en, :"pt-BR", :sv,
      ]
    end
  end

  describe ".locale_columns" do
    before do
      Article.translates :title
      I18n.default_locale = :fi
    end

    it "lists the columns-with-locale for that attribute, default locale first and then alphabetically" do
      Article.locale_columns(:title).should == [
        :title_fi, :title_en, :title_pt_br, :title_sv
      ]
    end

    it "supports multiple attributes" do
      Article.translates :body
      Article.locale_columns(:body, :title).should == [
        :body_fi, :body_en, :body_pt_br, :body_sv,
        :title_fi, :title_en, :title_pt_br, :title_sv
      ]
    end
  end

  describe "#title" do
    let(:article) {
      Article.new(:title_sv => "Hej", :title_en => "Halloa", :title_fi => "Moi moi")
    }

    before do
      Article.translates :title
      I18n.locale = :sv
      I18n.default_locale = :en
    end

    it "gives the title in the current locale" do
      article.title.should == "Hej"
    end

    it "falls back to the default locale if locale has no column" do
      I18n.locale = :ru
      article.title.should == "Halloa"
    end

    it "falls back to the default locale if blank" do
      article.title_sv = " "
      article.title.should == "Halloa"
    end

    it "does not fall back to any other locale if default locale is blank" do
      article.title_sv = " "
      article.title_en = ""
      article.title.should be_nil
    end

    it "returns nil if all are blank" do
      article.title_sv = " "
      article.title_en = ""
      article.title_fi = nil
      article.title.should be_nil
    end

    it "is overridable" do
      class Article
        def title
          super.reverse
        end
      end

      article.title.should == "jeH"
    end

    # Had a regression.
    it "handles multiple columns" do
      Article.translates :title, :body
      article.title_sv = "title"
      article.body_sv = "body"
      article.title.should == "title"
      article.body.should == "body"
    end

    it "reflects locale change" do
      article.title.should == "Hej"
      I18n.locale = :en
      article.title.should == "Halloa"
      I18n.locale = :sv
      article.title.should == "Hej"
    end

    context "with :fallback => false" do
      let(:article) {
        Article.new(:title_sv => "Hej", :title_en => "Halloa")
      }

      before do
        Article.translates :title, :fallback => false
        I18n.default_locale = :en
      end

      it "does not fall back to the default locale if locale has no column" do
        I18n.locale = :ru
        article.title.should be_nil
      end

      it "does not fall back to the default locale if blank" do
        I18n.locale = :sv
        article.title_sv = " "
        article.title.should be_nil
      end
    end
  end

  describe "#title=" do
    before do
      Article.translates :title
      I18n.locale = :sv
    end

    let(:article) { Article.new }

    it "assigns in the current locale" do
      article.title = "Hej"
      article.title.should == "Hej"
      article.title_sv.should == "Hej"
    end

    it "raises if locale has no column" do
      I18n.locale = :ru
      lambda {
        article.title = "Privet"
      }.should raise_error(NoMethodError, /title_ru/)
    end

    it "can be assigned properly with special locale" do
      I18n.locale = :"pt-BR"
      expect {
        article.title = 'pt-BR'
      }.to_not raise_error
    end
  end

  describe ".human_attribute_name" do
    before do
      Article.translates :title
      I18n.locale = :sv
    end

    it "appends a known language name" do
      Article.human_attribute_name(:title_en).should == "Titel (engelska)"
    end

    it "uses abbreviation when language name is not known" do
      Article.human_attribute_name(:title_fi).should == "Titel (FI)"
    end

    it "yields to defined translations" do
      Article.human_attribute_name(:title_sv).should == "Svensk titel"
    end

    it "passes through the default behavior" do
      Article.human_attribute_name(:title).should == "Titel"
    end

    it "passes through untranslated columns" do
      Article.human_attribute_name(:body_sv).should == "Body sv"
    end

    # ActiveModel::Errors#full_messages passes in an ugly default.

    it "does not yield to passed-in defaults" do
      Article.human_attribute_name(:title_en, :default => "Title en").should == "Titel (engelska)"
    end

    it "passes through defaults" do
      Article.human_attribute_name(:body_sv, :default => "Boday").should == "Boday"
    end
  end
end
