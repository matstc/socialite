# here add extensions to existing classes

class IdentityProxy
  def method_missing *args, &block
    self
  end
end
