module TerribleThings
  
  # Let's be really sure about the methods we call.
  class AreYouSure
    
    # we'll leave the special ones be
    def self.preserve_method? m
      m = m.to_s
      m == 'object_id' || m =~ /^__/ || m =~ /eval$/
    end
    
    self.instance_methods.each do |m|
      next if preserve_method? m
      undef_method m
    end
    
    (self.protected_methods + self.private_methods).each do |pm|
      next if preserve_method? pm
      define_method pm do |*args, &b|
        method_missing pm, *args, &b
      end
    end
    
    def initialize &block
      @block_binding = block.binding
      instance_eval &block
    end
    
    def yes?
      $stdin.gets =~ /^y/i
    end
    
    def prompt qualifier, meth
      $stdout.print "Are you #{qualifier} you want to invoke #{meth}? (y/N) "
    end
    
    def congratulate msg
      $stdout.puts "Good call! #{msg}!"
    end
    
    def method_missing meth, *args, &block
      prompt 'sure', meth
      if yes?
        prompt 'absolutely positive', meth
        if yes?
          # Real magic.
          real_work = eval("lambda { |*a,&b| #{meth}(*a, &b) }", @block_binding)
          real_work.call *args, &block
        else
          congratulate "Who knows what #{meth.inspect} really does"
        end
      else
        congratulate "When it comes to invoking #{meth.inspect}, it's better to be safe than sorry"
      end
    end
  end
  
end
