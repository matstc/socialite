class TestLogger
  def self.log message
    puts "TEST LOG: #{message}"
  end
end

class Hash
  def to_s
    collect {|k, v| "#{k} => #{v}"}.join ", "
  end
end
