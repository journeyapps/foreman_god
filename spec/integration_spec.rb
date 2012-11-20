# Run god and test it
require 'spec_helper'

OPTIONS = "-p 13985 -P spec/tmp/god.pid -l #{LOG_FILE} --no-syslog"

describe "god" do
  after do
    `god #{OPTIONS} terminate`
    FileUtils.rm_rf 'spec/simple/tmp'
  end

  it "should run and terminate a script" do
    `god #{OPTIONS} --attach #{Process.pid} -c spec/simple/simple.god`
    sleep 1
    `god #{OPTIONS} terminate`

    File.read('spec/tmp/simple-loop-1.log').should == "Starting simple loop\nTerminated loop with #<SignalException: SIGTERM>\n"
  end

  it "should restart a script on file touch" do
    `god #{OPTIONS} --attach #{Process.pid} -c spec/simple/simple.god`

    sleep 1

    FileUtils.mkdir_p 'spec/simple/tmp'
    FileUtils.touch 'spec/simple/tmp/restart.txt'

    sleep 6 # Currently the file is checked every 5 seconds

    `god #{OPTIONS} terminate`

    File.read('spec/tmp/simple-loop-1.log').should == "Starting simple loop\nTerminated loop with #<SignalException: SIGTERM>\n"*2
  end
end

