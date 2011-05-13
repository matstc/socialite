class AppSettings < RailsSettings::Settings
  def self.update_settings settings
    settings[:smtp_port] = settings[:smtp_port].to_i if settings[:smtp_port]

    if settings[:voting_momentum]
      settings[:voting_momentum] = settings[:voting_momentum].to_i 
      settings[:voting_momentum] = 2 if settings[:voting_momentum] < 2
    end

    settings = turn_ones_and_zeros_into_booleans settings

    settings.each {|k,v| self[k] = v }
  end

  private
  def self.turn_ones_and_zeros_into_booleans parameters
      parameters.each do |k,v|
        v = v == "1" ? true : v
        v = v == "0" ? false : v
        parameters[k] = v
      end
      parameters
  end
end
