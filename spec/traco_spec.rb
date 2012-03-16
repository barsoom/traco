require "spec_helper"
require "traco"

describe ActiveRecord::Base, ".translates" do

  it "should be available" do
    Post.should respond_to :translates
  end

end
