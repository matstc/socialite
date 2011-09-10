class Tweet
  include ActionView::Helpers::TextHelper

  def initialize user
    @user = user
  end

  def update message, url, flash
    return if !@user.linked_to? :twitter

    if url.length < 130
      begin
        raw_update message, url
      rescue Exception => e
        flash[:alert] = "We were not able to update Twitter. The error message was: #{e.message}."
      end
    else
      flash[:alert] = "We did not update Twitter as the url was too long: #{url}"
      Rails.logger.error("Did not tweet the following url as it is too long: " + url)
    end
  end

  private
  def raw_update message, url
    teaser = truncate(message, :length => (140 - url.length - 1))
    authentication = @user.authentications.find_by_provider :twitter
    authentication.update "#{teaser} #{url}"
  end

end
