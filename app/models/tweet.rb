class Tweet
  include ActionView::Helpers::TextHelper

  def initialize user
    @user = user
  end

  def update message, url, flash
    return if !@user.linked_to? :twitter

    begin
      if url.length < 130
        teaser = truncate(message, :length => (140 - url.length - 1))
        raw_update("#{teaser} #{url}")
      else
        Rails.logger.info("Did not tweet the following url as it is too long: " + url)
      end
    rescue
      flash[:alert] = "We were not able to update Twitter. The error message was: #{$!.message}."
    end
  end

  private
  def raw_update message
    authentication = @user.authentications.find_by_provider :twitter

    twitter = Twitter::Client::new \
      :oauth_token => authentication.token, \
      :oauth_token_secret => authentication.secret, \
      :consumer_key => AppSettings['twitter_consumer_key'], \
      :consumer_secret => AppSettings['twitter_consumer_secret']

    twitter.update message
  end

end
