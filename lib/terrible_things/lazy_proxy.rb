module TerribleThings
  # Giving Ruby the gift of lazy evaluation
  class LazyProxy < BasicObject
    
    class << self
      def enable
        Object.push_new do |b, c|
          if c && c < ::Enumerable
            ::TerribleThings::LazyEach.new b
          else
            new &b
          end
        end
      end
    end
    
    def initialize &promise
      @head = promise
    end
    
    def fulfill_method? m
      m.to_s =~ /^(to_s|inspect|to_str)$/
    end

    def method_missing meth, *args, &block
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
    
    def class
      LazyProxy
    end
    
    private
    def __fulfill_promise__ promise
      promise.call
    end
    def __fulfill_and_send__ promise, meth, args, block
      __fulfill_promise__(promise).__send__ meth, *args, &block
    end
  end
  
  class LazyEach < LazyProxy
    include ::Enumerable
    
    def initialize enum
      super(&enum)
    end
    
    def map &block
      ::TerribleThings::LazyMap.new @head, block
    end
    
    def each &block
      if block
        renum = __fulfill_and_send__(@head, :to_enum, [], nil)
        ::Kernel::loop do
          yield renum.next
        end
        self
      else
        self
      end
    end
    
    def class
      LazyEach
    end
  end
  
  class LazyMap < LazyEach
    def initialize enum, trans
      super(enum)
      @trans = trans
    end
    
    def each &block
      super() do |v|
        block.call @trans.call(v)
      end
    end
    
    def map &block
      super do |v|
        block.call @trans.call(v)
      end
    end
    
    def class
      LazyMap
    end
  end
  
  class LazyReduce < LazyEach
    def initialize enum, block
      super
      $stdout.puts "Building a reduction from #{enum}"
    end
  end
end
