class Logo
  attr_accessor :errors

  def initialize params={}
    @image = params[:image]
    @errors = []
  end

  def save
    begin
      new_logo_file_name = "logo" + File.extname(@image.original_filename)
      AppSettings.logo_file = new_logo_file_name

      path = File.join("public/images", new_logo_file_name)
      Rails.logger.info "writing new logo file to: #{path}"

      data = @image.read
      File.open(path, "wb") { |f| f.write(data) }
      return true
    rescue
      @errors.push $!.message
      return false
    end
  end
end
