class NilClass
  class << self
    # At the moment, this is a half-assed implementation of the Nothing
    # side of the Maybe monad.  It should return nil for every method, not
    # just the missing ones.
    
    attr_reader :monadic
    alias :monadic? :monadic
    
    def enable_monad
      @monadic = true
    end
    
    def disable_monad
      @monadic = false
    end
    
    def with_maybe
      orig, @monadic = @monadic, true
      begin
        yield
      ensure
        @monadic = orig
      end
    end
  end
  
  def method_missing_with_monadic meth, *args, &block
    if self.class.monadic?
      self
    else
      method_missing_without_monadic meth, *args, &block
    end
  end
  
  alias :method_missing_without_monadic :method_missing
  alias :method_missing :method_missing_with_monadic
end
