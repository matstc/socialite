xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title app_name
    xml.description "Popular submissions"
    xml.link root_url
    
    for submission in @submissions
      xml.item do
        xml.title submission.title
        xml.description submission.description
        xml.pubDate submission.created_at.to_s(:rfc822)
        xml.link submission_url(submission)
        xml.guid submission_url(submission)
      end
    end
  end
end


