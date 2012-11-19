# Run god and test it
require 'spec_helper'

OPTIONS = "-p 13985 -P spec/tmp/god.pid -l spec/tmp/god.log --no-syslog"

describe "god" do

  after do
    `god #{OPTIONS} terminate`
    FileUtils.rm_rf 'samples/simple/tmp'
  end

  it "should run and terminate a script" do
    `god #{OPTIONS} --attach #{Process.pid} -c spec/simple.god`
    sleep 1
    `god #{OPTIONS} terminate`
    #puts File.read('spec/tmp/god.log')
    File.read('spec/tmp/simple-loop-1.log').should == "Starting simple loop\nTerminated loop with #<SignalException: SIGTERM>\n"
  end

  it "should restart a script on file touch" do
    `god #{OPTIONS} --attach #{Process.pid} -c spec/simple.god`

    sleep 1

    FileUtils.mkdir_p 'samples/simple/tmp'
    FileUtils.touch 'samples/simple/tmp/restart.txt'

    sleep 5

    `god #{OPTIONS} terminate`
    #puts File.read('spec/tmp/god.log')
    File.read('spec/tmp/simple-loop-1.log').should == "Starting simple loop\nTerminated loop with #<SignalException: SIGTERM>\n"*2
  end
end

