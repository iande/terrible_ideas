module Kernel
  class Corrector
    extend Gem::Text
  end
  
  attr_reader :auto_correct
  alias :auto_correct? :auto_correct
  
  def enable_auto_correct
    @auto_correct = true
  end
  
  # We'll deliberately misspell this, just to show how awesome
  # auto-correcting is.
  def disable_auto_corretc
    @auto_correct = false
  end
  
  def with_auto_correction &block
    orig_correct, @auto_correct = @auto_correct, true
    begin
      yield
    ensure
      @auto_correct = orig_correct
    end
  end
  
  def method_missing_with_terrible_things meth, *args, &block
    meth_str = meth.to_s
    what_you_really_meant = methods.sort_by do |m|
      Corrector.levenshtein_distance meth_str, m.to_s
    end.first
    
    $stderr.puts "Hey, there's no method named: #{meth}!"
    $stderr.puts "\tDid you mean: #{what_you_really_meant}?"
    if auto_correct?
      __send__ what_you_really_meant, *args, &block
    else
      method_missing_without_terrible_things meth, *args, &block
    end
  end
  
  alias :method_missing_without_terrible_things :method_missing
  alias :method_missing :method_missing_with_terrible_things
end
