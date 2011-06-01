require 'spec_helper'

describe "kernel extensions" do
  let(:object) { Object.new }

  describe "auto-correct" do
    it "should not auto-correct by default" do
      object.auto_correct?.should be_false
    end
  
    it "should toggle auto-correcting (misspelled, of course)" do
      object.enable_auto_correct
      object.auto_correct?.should be_true
      object.disable_auto_corretc
      object.auto_correct?.should be_false
    end
  
    it "should auto-correct methods!!" do
      def object.my_stupendous_method
        42
      end
      object.enable_auto_correct
      object.my_stupneduos_method.should == 42
      # We should auto-correct this "misspelling"
      object.disable_auto_correct
      lambda { object.my_stupneduos_method }.should raise_error(NameError)
    end
  
    it "should allow selective auto-correcting" do
      object.auto_correct?.should be_false
      inspected = object.with_auto_correction { object.object_iz }
      object.auto_correct?.should be_false
      inspected.should == object.object_id
    end
  end
  
  describe "monadic nils" do
    it "should handle nil monadically" do
      lambda {
        with_maybe do
          nil.none_such.real_boy?
        end
      }.should_not raise_error
    end
    
    it "should not handle nil monadically by default" do
      lambda {
        nil.none_such
      }.should raise_error(NameError)
    end
  end
  
  describe "are you sure?" do
    let(:confident_code) { AreYouSureDouble.new }
    
    class AreYouSureDouble
      def guarded_method
        str = "my string"
        are_you_sure? do
          unguarded_method str.reverse
        end
      end
    end
    
    before(:each) do
      @orig_stdout, @orig_stdin = $stdout, $stdin
      $stdout = StringIO.new
      $stdin = mock('stdin')
    end
    
    after(:each) do
      $stdout, $stdin = @orig_stdout, @orig_stdin
    end
    
    it "should not execute if first prompt is explicitly denied" do
      $stdin.stub(:gets => "n\n")
      confident_code.should_not_receive(:unguarded_method)
      confident_code.guarded_method
      $stdout.string.should_not be_empty
    end
    
    it "should not execute if the first prompt is implicitly denied" do
      $stdin.stub(:gets => "\n")
      confident_code.should_not_receive(:unguarded_method)
      confident_code.guarded_method
      $stdout.string.should_not be_empty
    end
    
    it "should not execute if the second prompt is explicitly denied" do
      first_call = true
      $stdin.stub(:gets) do
        if first_call
          first_call = false
          "y\n"
        else
          "n\n"
        end
      end
      confident_code.should_not_receive(:unguarded_method)
      confident_code.guarded_method
      $stdout.string.should_not be_empty
    end
    
    it "should not execute if the second prompt is implicitly denied" do
      first_call = true
      $stdin.stub(:gets) do
        if first_call
          first_call = false
          "y\n"
        else
          "feathers\n"
        end
      end
      confident_code.should_not_receive(:unguarded_method)
      confident_code.guarded_method
      $stdout.string.should_not be_empty
    end
    
    it "should execute if both prompts are explicitly approved" do
      $stdin.stub(:gets => "y\n")
      confident_code.should_receive(:unguarded_method).with("my string".reverse)
      confident_code.guarded_method
      $stdout.string.should_not be_empty
    end
  end
end
