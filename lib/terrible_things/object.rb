class Object
  @@nested_news = []
  
  class << self
    def new_with_sugar *args, &block
      real_new = lambda do
        self.new_without_sugar *args, &block
      end
      @@nested_news.inject(real_new) do |nested, b|
        lambda { b.call nested, self }
      end.call
    end
    
    def push_new &block
      if @@nested_news.empty?
        instance_eval do
          alias :new_without_sugar :new
          alias :new :new_with_sugar
        end
      end
      @@nested_news << block
    end
    
    def pop_new
      @@nested_news.pop
      if @@nested_news.empty? && respond_to?(:new_without_sugar)
        instance_eval do
          alias :new :new_without_sugar
          undef :new_without_sugar
        end
      end
    end
  end
end