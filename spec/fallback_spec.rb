require "spec_helper"
require "traco"

describe Post do
  before do
    I18n.locale = :sv
    I18n.default_locale = :en
  end
  
  describe ".translates with :fallback => true" do
    before do
      Post.translates :title, :fallback => true
    end
    
    it "should return localized value if present" do
      post = Post.new(:title_sv => "Hej", :title_en => "Halloa", :title_fi => "Moi moi")
      post.title.should eq("Hej")
    end
    
    it "should fall back to default locale" do
      post = Post.new(:title_sv => nil, :title_en => "Halloa", :title_fi => "Moi moi")
      post.title.should eq("Halloa")
    end
    
    it "should fall back to other locales" do
      post = Post.new(:title_sv => nil, :title_en => nil, :title_fi => "Moi moi")
      post.title.should eq("Moi moi")
    end
  end
  
  describe ".translates with :fallback => false" do
    before do
      Post.translates :title, :fallback => false
    end
    
    it "should return localized value if present" do
      post = Post.new(:title_sv => "Hej", :title_en => "Halloa", :title_fi => "Moi moi")
      post.title.should eq("Hej")
    end
    
    it "should not fall back to other locales" do
      post = Post.new(:title_sv => nil, :title_en => "Halloa", :title_fi => "Moi moi")
      post.title.should be_nil
    end
  end
  
  describe ".translates with :fallback => :default_locale" do
    before do
      Post.translates :title, :fallback => :default_locale
    end
    
    it "should return localized value if present" do
      post = Post.new(:title_sv => "Hej", :title_en => "Halloa", :title_fi => "Moi moi")
      post.title.should eq("Hej")
    end
    
    it "should fall back to default locale" do
      post = Post.new(:title_sv => nil, :title_en => "Halloa", :title_fi => "Moi moi")
      post.title.should eq("Halloa")
    end
    
    it "should not fall back to other locales" do
      post = Post.new(:title_sv => nil, :title_en => nil, :title_fi => "Moi moi")
      post.title.should be_nil
    end
  end
end