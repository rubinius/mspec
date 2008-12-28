require File.dirname(__FILE__) + '/../spec_helper'
require 'mspec/ruby_name'
require 'mspec/guards/guard'
require 'rbconfig'

describe SpecGuard, ".register" do
  before :each do
    @tally = mock("tally")
    @tally.stub!(:register)
    TallyAction.stub!(:new).and_return(@tally)
    SpecGuard.instance_variable_set(:@registered, nil)
  end

  it "creates a new TallyAction if one does not exist" do
    TallyAction.should_receive(:new).and_return(@tally)
    @tally.should_receive(:register)
    SpecGuard.register
    SpecGuard.register
  end

  it "registers itself with MSpec :finish actions" do
    MSpec.should_receive(:register).with(:finish, SpecGuard)
    SpecGuard.register
  end
end

describe SpecGuard, ".unregister" do
  before :each do
    @tally = mock("tally")
    @tally.stub!(:register)
    TallyAction.stub!(:new).and_return(@tally)
    SpecGuard.instance_variable_set(:@registered, nil)
  end

  it "unregisters its tally action" do
    @tally.should_receive(:unregister)
    SpecGuard.register
    SpecGuard.unregister
  end
end

describe SpecGuard, ".windows?" do
  before(:all) do
    @ruby_platform = Object.const_get :RUBY_PLATFORM
  end

  after(:all) do
    Object.const_set :RUBY_PLATFORM, @ruby_platform
  end

  it "returns true if key is mswin32" do
    SpecGuard.windows?("mswin32").should be_true
  end

  it "returns true if key is mingw" do
    SpecGuard.windows?("mingw").should be_true
  end

  it "returns false for non-windows" do
    SpecGuard.windows?("notwindows").should be_false
  end

  it "uses RUBY_PLATFORM by default" do
    Object.const_set :RUBY_PLATFORM, "mswin32"
    SpecGuard.windows?.should be_true
  end
end

describe SpecGuard, "#yield?" do
  before :each do
    MSpec.clear_modes
    @guard = SpecGuard.new
  end

  it "returns true if MSpec.mode?(:verify) is true" do
    MSpec.register_mode :verify
    @guard.yield?.should == true
  end

  it "returns true if MSpec.mode?(:verify) is true regardless of invert being true" do
    MSpec.register_mode :verify
    @guard.yield?(true).should == true
  end

  it "returns true if MSpec.mode?(:report) is true" do
    MSpec.register_mode :report
    @guard.yield?.should == true
  end

  it "returns true if MSpec.mode?(:report) is true regardless of invert being true" do
    MSpec.register_mode :report
    @guard.yield?(true).should == true
  end

  it "returns #match? if neither report nor verify mode are true" do
    @guard.stub!(:match?).and_return(false)
    @guard.yield?.should == false
    @guard.stub!(:match?).and_return(true)
    @guard.yield?.should == true
  end

  it "returns #match? if invert is true and neither report nor verify mode are true" do
    @guard.stub!(:match?).and_return(false)
    @guard.yield?(true).should == true
    @guard.stub!(:match?).and_return(true)
    @guard.yield?(true).should == false
  end
end

describe SpecGuard, "#===" do
  it "returns true" do
    anything = mock("anything")
    SpecGuard.new.===(anything).should == true
  end
end

describe SpecGuard, "#implementation?" do
  before :all do
    @verbose = $VERBOSE
    $VERBOSE = nil
  end

  after :all do
    $VERBOSE = @verbose
  end

  before :each do
    @ruby_name = Object.const_get :RUBY_NAME
    @guard = SpecGuard.new
  end

  after :each do
    Object.const_set :RUBY_NAME, @ruby_name
  end

  it "returns true if passed :ruby and RUBY_NAME == 'ruby'" do
    Object.const_set :RUBY_NAME, 'ruby'
    @guard.implementation?(:ruby).should == true
  end

  it "returns true if passed :rbx and RUBY_NAME == 'rbx'" do
    Object.const_set :RUBY_NAME, 'rbx'
    @guard.implementation?(:rbx).should == true
  end

  it "returns true if passed :rubinius and RUBY_NAME == 'rbx'" do
    Object.const_set :RUBY_NAME, 'rbx'
    @guard.implementation?(:rubinius).should == true
  end

  it "returns true if passed :jruby and RUBY_NAME == 'jruby'" do
    Object.const_set :RUBY_NAME, 'jruby'
    @guard.implementation?(:jruby).should == true
  end

  it "returns false when passed an unrecognized name" do
    Object.const_set :RUBY_NAME, 'ruby'
    @guard.implementation?(:python).should == false
  end
end

describe SpecGuard, "#platform?" do
  before :all do
    @verbose = $VERBOSE
    $VERBOSE = nil
  end

  after :all do
    $VERBOSE = @verbose
  end

  before :each do
    @ruby_platform = Object.const_get :RUBY_PLATFORM
    Object.const_set :RUBY_PLATFORM, 'solarce'
    @guard = SpecGuard.new
  end

  after :each do
    Object.const_set :RUBY_PLATFORM, @ruby_platform
  end

  it "returns false when arg does not match RUBY_PLATFORM" do
    @guard.platform?(:ruby).should == false
  end

  it "returns false when no arg matches RUBY_PLATFORM" do
    @guard.platform?(:ruby, :jruby, :rubinius).should == false
  end

  it "returns true when arg matches RUBY_PLATFORM" do
    @guard.platform?(:solarce).should == true
  end

  it "returns true when any arg matches RUBY_PLATFORM" do
    @guard.platform?(:ruby, :jruby, :solarce, :rubinius).should == true
  end

  it "returns true when arg is :windows and RUBY_PLATFORM contains 'mswin'" do
    Object.const_set :RUBY_PLATFORM, 'i386-mswin32'
    @guard.platform?(:windows).should == true
  end

  it "returns true when arg is :windows and RUBY_PLATFORM contains 'mingw'" do
    Object.const_set :RUBY_PLATFORM, 'i386-mingw32'
    @guard.platform?(:windows).should == true
  end

  it "returns false when arg is not :windows and Config::CONFIG['host_os'] contains 'mswin'" do
    Object.const_set :RUBY_PLATFORM, 'i386-mswin32'
    @guard.platform?(:linux).should == false
  end

  it "returns false when arg is not :windows and Config::CONFIG['host_os'] contains 'mingw'" do
    Object.const_set :RUBY_PLATFORM, 'i386-mingw32'
    @guard.platform?(:linux).should == false
  end
end

describe SpecGuard, "#platform? on JRuby" do
  before :all do
    @verbose = $VERBOSE
    $VERBOSE = nil
  end

  after :all do
    $VERBOSE = @verbose
  end

  before :each do
    @ruby_platform = Object.const_get :RUBY_PLATFORM
    Object.const_set :RUBY_PLATFORM, 'java'
    @guard = SpecGuard.new
  end

  after :each do
    Object.const_set :RUBY_PLATFORM, @ruby_platform
  end

  it "returns true when arg is :java and RUBY_PLATFORM contains 'java'" do
    @guard.platform?(:java).should == true
  end

  it "returns true when arg is :windows and RUBY_PLATFORM contains 'java' and os?(:windows) is true" do
    Config::CONFIG.stub!(:[]).and_return('mswin32')
    @guard.platform?(:windows).should == true
  end

  it "returns true when RUBY_PLATFORM contains 'java' and os?(argument) is true" do
    Config::CONFIG.stub!(:[]).and_return('amiga')
    @guard.platform?(:amiga).should == true
  end
end

describe SpecGuard, "#wordsize?" do
  before :each do
    @guard = SpecGuard.new
  end

  it "returns true when arg is 32 and 1.size is 4" do
    @guard.wordsize?(32).should == (1.size == 4)
  end

  it "returns true when arg is 64 and 1.size is 8" do
    @guard.wordsize?(64).should == (1.size == 8)
  end
end

describe SpecGuard, "#os?" do
  before :each do
    @guard = SpecGuard.new
    Config::CONFIG.stub!(:[]).and_return('unreal')
  end

  it "returns true if argument matches Config::CONFIG['host_os']" do
    @guard.os?(:unreal).should == true
  end

  it "returns true if any argument matches Config::CONFIG['host_os']" do
    @guard.os?(:bsd, :unreal, :amiga).should == true
  end

  it "returns false if no argument matches Config::CONFIG['host_os']" do
    @guard.os?(:bsd, :netbsd, :amiga, :msdos).should == false
  end

  it "returns false if argument does not match Config::CONFIG['host_os']" do
    @guard.os?(:amiga).should == false
  end

  it "returns true when arg is :windows and Config::CONFIG['host_os'] contains 'mswin'" do
    Config::CONFIG.stub!(:[]).and_return('i386-mswin32')
    @guard.os?(:windows).should == true
  end

  it "returns true when arg is :windows and Config::CONFIG['host_os'] contains 'mingw'" do
    Config::CONFIG.stub!(:[]).and_return('i386-mingw32')
    @guard.os?(:windows).should == true
  end

  it "returns false when arg is not :windows and Config::CONFIG['host_os'] contains 'mswin'" do
    Config::CONFIG.stub!(:[]).and_return('i386-mingw32')
    @guard.os?(:linux).should == false
  end

  it "returns false when arg is not :windows and Config::CONFIG['host_os'] contains 'mingw'" do
    Config::CONFIG.stub!(:[]).and_return('i386-mingw32')
    @guard.os?(:linux).should == false
  end
end

describe SpecGuard, "windows?" do
  before :each do
    @guard = SpecGuard.new
  end

  it "returns false if not passed :windows" do
    @guard.windows?(:linux, 'mswin32').should == false
    @guard.windows?(:linux, 'i386-mingw32').should == false
  end

  it "returns true if passed :windows and the key matches 'mswin' or 'mingw'" do
    @guard.windows?(:windows, 'mswin32').should == true
    @guard.windows?(:windows, 'i386-mingw32').should == true
  end

  it "returns false if passed :windows and the key matches neither 'mswin' nor 'mingw'" do
    @guard.windows?(:windows, 'darwin9.0').should == false
    @guard.windows?(:windows, 'linux').should == false
  end
end

describe SpecGuard, "#match?" do
  before :each do
    @guard = SpecGuard.new
    SpecGuard.stub!(:new).and_return(@guard)
  end

  it "returns true if #platform? or #implementation? return true" do
    @guard.stub!(:implementation?).and_return(true)
    @guard.stub!(:platform?).and_return(false)
    @guard.match?.should == true

    @guard.stub!(:implementation?).and_return(false)
    @guard.stub!(:platform?).and_return(true)
    @guard.match?.should == true
  end

  it "returns false if #platform? and #implementation? return false" do
    @guard.stub!(:implementation?).and_return(false)
    @guard.stub!(:platform?).and_return(false)
    @guard.match?.should == false
  end
end

describe SpecGuard, "#unregister" do
  before :each do
    @tally = mock("tally")
    @tally.stub!(:register)
    TallyAction.stub!(:new).and_return(@tally)
    MSpec.stub!(:unregister)
    @guard = SpecGuard.new

    SpecGuard.instance_variable_set(:@registered, nil)
    SpecGuard.register
  end

  it "unregisters from MSpec :exclude actions" do
    MSpec.should_receive(:unregister).with(:exclude, @guard)
    @tally.should_receive(:unregister)
    @guard.unregister
  end

  it "unregisters from MSpec :after actions" do
    MSpec.should_receive(:unregister).with(:after, @guard)
    @tally.should_receive(:unregister)
    @guard.unregister
  end

  it "invokes the class's unregister method" do
    SpecGuard.should_receive(:unregister)
    @guard.unregister
  end
end
