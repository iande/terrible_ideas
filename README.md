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

## Future Features

I should have more to put here by this weekend.  Maybe not, it's hard to
say how long I want to keep this going.

## Contributing

It's important to me that any contributions be tested.  I'm currently using
rspec, but given its verbose output when testing this gem, I'm open to
other suggestions.  But, your code should be tested and have >=90% code
coverage.  Contributions should also have the appearance of being
useful, ASCII penises need not apply.
