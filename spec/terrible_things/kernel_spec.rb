require 'spec_helper'

describe "kernel extensions" do
  let(:object) { Object.new }
  
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
end
