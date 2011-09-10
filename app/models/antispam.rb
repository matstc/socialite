class Antispam
  def initialize memory_path="antispam-memory"
    bayes = Classifier::Bayes.new :spam, :content
    @madeleine = SnapshotMadeleine.new(memory_path) {bayes}
    @bayes = @madeleine.system
  end

  def is_spam? stringable
    category, score = compute_uncertainty(stringable)
    score > -5 and category == 'Spam'
  end

  def is_classified_as_content? stringable
    @bayes.classify(stringable.to_s) == 'Content'
  end
  
  def is_classified_as_spam? stringable
    @bayes.classify(stringable.to_s) == 'Spam'
  end

  def switch_to_spam stringable
    @bayes.untrain(:content, stringable.to_s)
    @bayes.train(:spam, stringable.to_s)
    @madeleine.take_snapshot

    Rails::logger.info("Switching to spam. We would now classify the stringable as follows.")
    compute_uncertainty stringable
  end

  def switch_to_content stringable
    @bayes.untrain(:spam, stringable.to_s)
    @bayes.train(:content, stringable.to_s)
    @madeleine.take_snapshot

    Rails::logger.info("Switching to content. We would now classify the stringable as follows.")
    compute_uncertainty stringable
  end

  def train_as_spam stringable
    @bayes.train :spam, stringable.to_s
    @madeleine.take_snapshot
  end

  def train_as_content stringable
    @bayes.train :content, stringable.to_s
    @madeleine.take_snapshot
  end

  def trained_entries
    @bayes.instance_variable_get :@total_words
  end

  # returns [category, score]
  def compute_uncertainty stringable
    scores = @bayes.classifications(stringable.to_s)
    winner, loser = scores.sort_by{ |a| -a[1] }
    Rails::logger.info "The classifier thinks stringable '#{stringable}' is '#{winner[0]}' with a certainty of #{winner[1]} (#{loser[0]} = #{winner[1]})"
    winner
  end

end
