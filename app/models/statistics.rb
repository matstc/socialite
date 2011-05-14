class Statistics
  def self.load
    stats = {}
    stats[:number_of_users] = User.count
    stats[:number_of_submissions] = Submission.count
    stats[:number_of_submissions_this_week] = Submission.where(['submissions.created_at > ?', 1.week.ago]).count
    stats[:time_of_last_registration] = User.order("created_at desc").first.created_at
    stats
  end
end
