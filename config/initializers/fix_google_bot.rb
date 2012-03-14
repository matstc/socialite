# This bit of code fixes some rails internals to handle the requests coming in from the google mobile bot crawler
# See https://gist.github.com/1668070
module Mime
  class Type
    def self.lookup(string)
      string = string.gsub(/\\/, "")
      string = string.gsub(/text\/\*/, "*")
      LOOKUP[string.split(';').first]
    end
  end
end
