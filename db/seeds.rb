# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# random text taken from wikipedia
@@text = %{The International Monetary Fund was conceived in July 1944 during the United Nations Monetary and Financial Conference. The representatives of 45 governments met in the Mount Washington Hotel in the area of Bretton Woods, New Hampshire, United States, with the delegates to the conference agreeing on a framework for international economic cooperation.[14] The IMF was formally organized on December 27, 1945, when the first 29 countries signed its Articles of Agreement. The statutory purposes of the IMF today are the same as when they were formulated in 1943 (see #Assistance and reforms).

The IMF's influence in the global economy steadily increased as it accumulated more members. The number of IMF member countries has more than quadrupled from the 44 states involved in its establishment, reflecting in particular the attainment of political independence by many developing countries and more recently the collapse of the Soviet bloc. The expansion of the IMF's membership, together with the changes in the world economy, have required the IMF to adapt in a variety of ways to continue serving its purposes effectively.

In 2008, faced with a shortfall in revenue, the International Monetary Fund's executive board agreed to sell part of the IMF's gold reserves. On April 27, 2008, IMF Managing Director Dominique Strauss-Kahn welcomed the board's decision of April 7, 2008 to propose a new framework for the fund, designed to close a projected $400 million budget deficit over the next few years. The budget proposal includes sharp spending cuts of $100 million until 2011 that will include up to 380 staff dismissals.}

def random_text
  words = @@text.split
  first = rand(words.size - 56)
  length = rand(55) + 1
  words[first, length].join " "
end

def random_submission
  rand_id = rand(Submission.count)
  rand_record = Submission.first(:conditions => [ "id >= ?", rand_id])
end

def random_user
  rand_id = rand(User.count)
  rand_record = User.first(:conditions => [ "id >= ?", rand_id])
end

def create_users
  users = "john mike paul betty ashley ricky jane minnie mickey sally harry hermione tom slim jim colin smith gordon gunther emily veronica ed al matt henry bob richard sandra lizzie deborah barbie".split.map do |username|
    {:username => username, :email => "#{username}@example.com", :password => '123456', :karma => (rand(500) + 1)}
  end

  User.create!(users)
  User.all.first.update_attribute :admin, true
  User.all.each {|user| user.update_attribute :confirmed_at, Time.now}
  User.all[1,6].each{|user| user.mark_as_deleted}
end

def create_submissions
  default_sub = lambda {{:url => "example.com", :title => random_text, :description => random_text, :created_at => rand(9900).minutes.ago, :score => rand(80), :user => random_user}}
  25.times do
    Submission.create!([default_sub.call.merge :is_spam => false])
  end
  3.times do
    Submission.create!([default_sub.call.merge :is_spam => true])
  end
end

def create_comments
  Submission.all.each do |submission|
    rand(4).times do
      comment = Comment.create!([{:submission => submission, :text => random_text, :user => random_user}]).first
      if rand(2) == 0
        Comment.create!([{:parent => comment, :submission => submission, :text => random_text, :user => random_user}])
      end
    end
  end
end

def create_votes
  50.times do
    vote = Vote.new :user => random_user, :submission => random_submission
    vote.save!
  end
end

create_users
create_submissions
create_comments
create_votes
