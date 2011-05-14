require 'spec_helper'

describe Submission do

  it "should not count spam towards comment count" do
    submission = ObjectMother.create_submission
    comment = ObjectMother.create_comment :submission => submission, :is_spam => true
    submission.comments.size.should == 0

    comment = ObjectMother.create_comment :submission => submission
    submission.reload
    submission.comments.size.should == 1

    deleted_user = ObjectMother.create_user :deleted => true
    comment = ObjectMother.create_comment :submission => submission, :user => deleted_user
    submission.reload
    submission.comments.size.should == 1
  end

  it "should allow blank urls" do
    submission = ObjectMother.create_submission :url => ""
    submission.url.should == ""
  end

  it "should pull out the most recent" do
    recent = ObjectMother.create_submission :created_at => 1.minute.ago
    old = ObjectMother.create_submission :created_at => 10.minutes.ago

    most_recent = Submission.most_recent.all
    most_recent.should eq([recent, old])
  end

  it "should pull out the best of sorted best first" do
    best = ObjectMother.create_submission :score => 2
    second_best = ObjectMother.create_submission :score => 1

    best_of = Submission.best_of.all
    best_of.should eq([best, second_best])
  end

  it "should not pull the spam submissions" do
    legit_submission = ObjectMother.create_submission :is_spam => false
    spam_submission = ObjectMother.create_submission :is_spam => true

    list = Submission.list
    list.should include(legit_submission)
    list.should_not include(spam_submission)
  end
  
  it 'should start with a score of 0' do
    submission = Submission.new(:user => User.new)
    submission.score.should eq(0)
  end
  
  it 'increases the score when you vote it up' do
    submission = Submission.new(:user => User.new)
    submission.vote_up(User.new).score.should eq(1)
  end

  it "should return only the top-level comments" do
    parent_comment = Comment.new :user => User.new
    child_comment = Comment.new(:parent => parent_comment, :user => User.new)
    submission = Submission.new(:comments => [parent_comment, child_comment])
    
    submission.top_level_comments.should eq([parent_comment])
  end

  it "should calculate interestingness correctly" do
    now = Time.now
    that = Submission.new(:created_at => now, :score => 2)
    other = Submission.new(:created_at => now, :score => 3)

    assert that.interestingness < other.interestingness
  end

  it "should consider a week-old submission with 35 points to be as interesting as a new one" do
    AppSettings.voting_momentum = 5
    
    now = Time.now
    poor_submission = ObjectMother.create_submission(:created_at => now, :score => 0)
    good_submission = ObjectMother.create_submission(:created_at => now, :score => 2)
    old_submission = ObjectMother.create_submission(:created_at => now - 1.week, :score => 36)

    poor_submission.interestingness.should be < old_submission.interestingness
    good_submission.interestingness.should be > old_submission.interestingness

    poor_submission.save!
    good_submission.save!
    old_submission.save!
    Submission.ordered.all.should == [good_submission, old_submission, poor_submission]
  end

  it "should update interestingness when the voting momentum changes" do
    AppSettings.voting_momentum = 10
    
    now = Time.now
    poor_submission = ObjectMother.create_submission(:created_at => now, :score => 0)
    good_submission = ObjectMother.create_submission(:created_at => now, :score => 2)
    old_submission = ObjectMother.create_submission(:created_at => now - 1.week, :score => 71)

    poor_submission.interestingness.should be < old_submission.interestingness
    good_submission.interestingness.should be > old_submission.interestingness

    poor_submission.save!
    good_submission.save!
    old_submission.save!
    Submission.ordered.all.should == [good_submission, old_submission, poor_submission]
  end

  it "should turn all urls into absolute urls" do
    Submission.new(:url => "example.com").url.should eq("http://example.com")
    Submission.new(:url => "ftp://example.com").url.should eq("ftp://example.com")
    Submission.new(:url => "http://example.com").url.should eq("http://example.com")
  end

  it "should not allow two votes from the same user" do
    voter = User.new
    submission = Submission.new(:user => User.new)
    submission.vote_up(voter).vote_up(voter).score.should eq(1)
  end

  it "should not allow a user to vote for their own submission" do
    user = User.new
    submission = Submission.new(:user => user)
    submission.vote_up(user).score.should eq(0)
  end
end
