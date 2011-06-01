module TerribleThings
  # Giving Ruby the gift of lazy evaluation
  class LazyProxy < BasicObject
    
    class << self
      def enable
        Object.push_new do |b, c|
          new c, &b
        end
      end
    end
    
    def initialize proxying=nil, &promise
      @proxying = proxying
      @head = promise
    end
    
    def respond_to? _
      true
    end
    
    def fulfill_method? m
      m.to_s =~ /^(to_s|inspect|to_str|exception)$/
    end

    def method_missing meth, *args, &block
      #$stdout.puts "Method missing #{meth} [#{@proxying.inspect}]"
      if fulfill_method? meth
        __fulfill_and_send__ @head, meth, args, block
      else
        @head = ::Kernel::lambda do |promise|
          ::Kernel::lambda do
            __fulfill_and_send__ promise, meth, args, block
          end
        end.call(@head)
        self
      end
    end
    
    private
    def __fulfill_promise__ promise
      promise.call
    end
    def __fulfill_and_send__ promise, meth, args, block
      __fulfill_promise__(promise).__send__ meth, *args, &block
    end
  end
end
