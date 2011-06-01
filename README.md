# Terrible Things

Inspired by a question posed by oddmunds, I decided to put together a gem
of terrible ideas.  Here are some of its current features.

## Current Features

### Method Auto Correction

Ever get tired of NameError's being raised as a result of a silly typo in
a method name?  Your hours of weeping and gnashing of teeth can now be
resolved effortlessly.  This idea was put forth by oddmunds on freenode.

Toggle auto correction on your objects:

    class MyClass
      def initialize
        enable_auto_correct
      end
      
      def my_super_method
        # Make sweet music
      end
      
      def my_other_method
        my_spure_method
      end
    end
    
    my_inst = MyClass.new
    my_inst.my_other_method
    
With auto-correction enabled, you can rest assured that `my_ins.my_other_method`
will indeed make sweet music.

Have a typo buried in code but don't have time to track it down?  No problem!
You can either manually toggle auto-correction:

    def from_str_to_sym str
      str.to_sym
    end
    
    def from_sym_to_str sym
      sym.to_s
    end

    def my_convoluted_method *args
      enable_auto_correct
      args.map do |a|
        if a.to_i > 0
          a.to_i * 5
        else
          case a
          when String
            from_str_to_smy a
          when Symbol
            from_sym_tos_tr a
          else
          end
        end
        disable_auto_correct
      end
    end
    
or, you can evaluate a specific block with auto-correction enabled:

    def my_convoluted_method *args
      args.map do |a|
        if a.to_i > 0
          a.to_i * 5
        else
          with_auto_correction do
            case a
            when String
              from_str_to_smy a
            when Symbol
              from_sym_tos_tr a
            else
            end
          end
        end
      end
    end
    
If you need further proof of auto-correction's capabilities, the method
`disable_auto_correct` is deliberately misspelled as `disable_auto_corretc`.
This gives auto-correction one last chance to prove its love to you before
shutting itself off.

### Write Code Confidently!

How can you write "confident code" when you're not quite sure what wicked
sorcery is being performed behind opaque method names?  Fear not, we're
working on a solution that will let you code confidently with a clear
conscience: meet `are_you_sure?`.

    class MyModel < ActiveRecord::Base
    
      def self.recent min_created_at = nil   
        # Who knows what dark arts are being performed by arel's
        # "convenient" methods?
        min_created_at ||= Time.now.advance(:days => -5)
        are_you_sure? do
          where "created_at >= ?", min_created_at
        end
      end
    
    end

By forcing users to confirm method invocations, you are freed from all
expectations and liabilities.  After all, if the end users confirm the
method call, any blame for unintended results falls squarely on their
shoulders.  By examining the shortcomings of EULA prompts, we opted to make
"deny" the default behavior to prevent users from blindly pressing the
return key!

While this method is certainly handy, we intend to make it even handier in
the future.  Right now we are only trapping method invocations, but with a
little luck, we will be able to capture more than that soon!

### Monadic NilClass

The Maybe monad is powerful stuff, and while
[others have proposed custom classes](http://avdi.org/devblog/2011/05/30/null-objects-and-falsiness/)
to encapsulate this behavior, doing so loses Ruby's notion of `nil` being
`falsey`, so we bake this goodness right into NilClass!


    def method_that_might_return_nil
      # ...
    end
    
    def method_using_monadic_nils
      with_maybe do
        method_that_might_return_nil.keen_instance_method.reverse
      end
    end

## Future Features

* Let's take probabilistic models to their natural conclusion: guessing
  which arguments a user *meant* to pass to a method.

* Do some "on-the-fly" benchmarking to identify what methods are taking too
  long (or are too complex) and stop calling them for great scalability.

I should have more to put here by this weekend.  Maybe not, it's hard to
say how long I want to keep this going.

## Contributing

It's important to me that any contributions be tested.  I'm currently using
rspec, but given its verbose output when testing this gem, I'm open to
other suggestions.  But, your code should be tested and have >=90% code
coverage.  Contributions should also have the appearance of being
useful, ASCII penises need not apply.
