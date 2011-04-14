class Favicon
  attr_accessor :errors, :path

  def initialize params={}
    @image = params[:image]
    @errors = []
    @path = "public/favicon.ico"
  end

  def save
    begin
      File.open(@path, "wb") { |f| f.write(@image.read) }
      true
    rescue
      @errors.push $!.message
      false
    end
  end
end
