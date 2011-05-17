require 'spec_helper'

describe Antispam do
  before :each do
    FileUtils.rm_rf("test-antispam-memory") if File.exists? "test-antispam-memory"
    @antispam = Antispam.new "test-antispam-memory"
    @submission = Submission.new(:title => "title", :description => "description")
  end

  it "should reload snapshot if found" do
    @antispam.trained_entries.should eq(0)

    @antispam.train_as_content @submission
    @antispam.trained_entries.should eq(2)

    Antispam.new("test-antispam-memory").trained_entries.should eq(2)
  end

  it "should untrain when switching to spam" do 
    @antispam.trained_entries.should eq(0)
    @antispam.train_as_content @submission
    @antispam.trained_entries.should eq(2)
    @antispam.switch_to_spam @submission
    @antispam.trained_entries.should eq(2)
  end

  it "should not throw an error when trying to untrain when there are no words in the classifier" do
    @antispam.switch_to_spam @submission
  end

  it "should be very uncertain at the beginning and then have some certainty" do
    @antispam.compute_uncertainty(@submission)[1].should eq(-1/0.0)
    @antispam.train_as_spam(@submission)
    category, score = @antispam.compute_uncertainty(@submission)
    category.should == 'Spam'
    score.should be > (-1/0.0)
  end

  it "should untrain as spam and switch to content" do
    # we train once for each category to help drive out issues when the classifier is new
    @antispam.train_as_content "legitimate content"
    @antispam.train_as_spam "some viagra"

    @antispam.train_as_spam @submission
    @antispam.is_classified_as_spam?(@submission).should eq(true)
    @antispam.trained_entries.should eq(5)

    @antispam.switch_to_content @submission
    @antispam.is_classified_as_content?(@submission).should eq(true)
    @antispam.trained_entries.should eq(5)
  end
end

