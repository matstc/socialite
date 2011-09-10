class Authentication < ActiveRecord::Base
  belongs_to :user

  def update message
    if self.provider == "twitter"

      twitter = Twitter::Client::new \
        :oauth_token => self.token, \
        :oauth_token_secret => self.secret, \
        :consumer_key => AppSettings['twitter_consumer_key'], \
        :consumer_secret => AppSettings['twitter_consumer_secret']

      return twitter.update message
    end

    raise "We don't know how to handle provider #{self.provider}"
  end
end
