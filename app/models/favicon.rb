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
      return true
    rescue
      @errors.push $!.message
      return false
    end
  end
end
