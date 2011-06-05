module TerribleThings
  # Giving Ruby the gift of lazy evaluation
  class LazyProxy < BasicObject
    class Promise < BasicObject
      def initialize prior, meth=nil, args=[], block=nil, trans=nil
        @prior = prior
        @method = meth
        @args = args
        @block = block
        @trans = trans
      end
      
      def stack meth, args=[], block=nil
        Promise.new(self, meth, args, block)
      end
      
      def apply block
        Promise.new(self, nil, [], nil, block)
      end
      
      def call
        unless defined?(@fulfilled)
          #$stdout.puts "Fulfilling: #{inspect}"
          @fulfilled = @prior.call
          @fulfilled = @fulfilled.__send__ @method, *@args, &@block if @method
          @fulfilled = @trans.call(@fulfilled) if @trans
        end
        @fulfilled
      end
      
      def inspect
        if @fulfilled
          "Just #{@fulfilled.class}"
        elsif @method
          "'#{@method.inspect}' [#{@prior.inspect}]"
        elsif @trans
          "Trans [#{@prior.inspect}]"
        else
          "Just Proc"
        end
      end
      alias :to_s :inspect
      
      def is_a? t
        t == Promise
      end
    end
    
    class << self
      def enable
        Object.push_new do |b, c|
          unless c <= ::Exception
            new b, c
          else
            b.call
          end
        end
      end
    end
    
    def initialize block, wrap=nil
      @promise = block.is_a?(Promise) ? block : Promise.new(block)
      @wrapped = wrap
      if wrap && wrap < ::Enumerable
        class << self
          include LazyEnumerable
        end
      end
    end
    
    def tee
      LazyProxy.new(@promise)
    end

    def method_missing meth, *args, &block
      if [:to_s, :to_str, :inspect, :coerce].include?(meth)
        @promise.call.__send__ meth, *args, &block
      else
        @promise = @promise.stack(meth, args, block)
        #$stdout.puts "Wound: #{@promise.inspect}"
        self.tee
      end
    end
    
    def promise
      @promise
    end
    
    def class
      LazyProxy
    end
  end
  
  module LazyEnumerable
    def map &block
      LazyMapping.new self, &block
    end
    alias :collect :map
    
    def select &block
      LazyFiltering.new self, &block
    end
    alias :find_all :select
    
    def reject &block
      select { |e| !block.call(e) }
    end
    
    # Not optimal, but we'll get there eventually
    def detect &block
      select(&block).first
    end
    alias :find :detect
  end
  
  class LazyEnumerator < BasicObject
    include ::Enumerable
    include LazyEnumerable
    
    def initialize enum
      @enumerable = enum
      @enum = enum.tee.to_enum
    end
    
    def method_missing meth, *args, &block
      @enum.tee.__send__ meth, *args, &block
    end
    
    def each &block
      if block
        self.rewind
        ::Kernel::loop do
          yield self.next
        end
        self.rewind
      end
      self
    end
    
    def rewind; @enum.rewind; end
    def to_enum; self; end
    def tee; self; end
  end

  class LazyMapping < LazyEnumerator
    def initialize enum, &trans
      super(enum)
      @transform = trans
    end
    
    def next
      @transform.call @enum.tee.next
    end
  end
  
  class LazyFiltering < LazyEnumerator
    def initialize enum, &filter
      super(enum)
      @filter = filter
    end
    
    # I don't see a way around calling here.
    def next
      ::Kernel::loop do
        nx = @enum.tee.next
        break nx if @filter.call(nx.promise.call)
      end
    end
  end
end
