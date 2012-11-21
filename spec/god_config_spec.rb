require 'spec_helper'
require 'foreman_god/god_config'
require 'god'
require 'etc'

describe GodConfig do
  context "simple" do
    let(:config) { GodConfig.new(sample('simple')) }

    it "should load basic properties" do
      config.dir_name.should == 'simple'
      config.app_name.should == 'simple'
      config.options.should == {}
    end

    it "should watch" do
      config.watch
      God.watches.values.count.should == 1
      watch = God.watches.values.first
      watch.should be

      File.absolute_path(watch.dir).should == sample('simple')
      watch.name.should == 'simple-loop-1'
      watch.group.should == 'simple'
      watch.interval.should == 60.seconds
      watch.env.should == {'PORT' => '5000'}
      watch.start.should == 'ruby ../simple_loop.rb -p 5000'
      watch.log.should == '/dev/null'

      watch.uid.should == nil # The user name is the same as the current user
      watch.gid.should == nil
    end

    it "should log if log is specified" do
      begin
        FileUtils.mkdir 'samples/simple/log'
        config.watch
        watch = God.watches.values.first
        watch.log.should == File.absolute_path('samples/simple/log/simple-loop-1.log')
      ensure
        FileUtils.rm_rf 'samples/simple/log'
      end
    end

    it "should default to using the owner of Procfile as the user" do
      user_name = Etc.getpwuid(File.stat('samples/simple/Procfile').uid).name
      config.user_name.should == user_name
    end

  end

  context "configuration" do
    let(:user) { Etc.getlogin }
    let(:config) { GodConfig.new(sample('configuration')) }

    it "should load basic properties" do
      config.dir_name.should == 'configuration'
      config.app_name.should == 'configured-app'
      config.user_name.should == 'test'
      config.options.should ==  {"formation"=>"loop=1,another=2", "app"=>"configured-app", "user"=>"test", "log" => "."}
    end

    it "should watch" do
      config = GodConfig.new(sample('configuration'), user: user) # we need to override the user here

      config.watch
      God.watches.values.count.should == 3
      watch = God.watches.values.first
      watch.should be

      File.absolute_path(watch.dir).should == sample('configuration')
      watch.name.should == 'configured-app-loop-1'
      watch.group.should == 'configured-app'
      watch.interval.should == 60.seconds
      watch.env.should == {'PORT' => '5000', 'MY_VAR' => '12345', 'ANOTHER_VAR' => 'yes'}
      watch.start.should == 'ruby ../simple_loop.rb -p 5000'
      watch.log.should == File.absolute_path('samples/configuration/configured-app-loop-1.log')

      # We cannot easily test watch.uid in a single-user setup
      pending "Test watch.uid"
      #watch.uid.should == user
      #watch.gid.should == ?
    end
  end

  it "should glob" do
    # This should match spec/simple
    ForemanGod.watch 'spec/*'
    God.watches.values.count.should == 1
  end

  it "should not use 'current' for the app name" do
    FileUtils.mkdir_p 'spec/tmp/test/current'
    FileUtils.touch 'spec/tmp/test/current/Procfile'
    GodConfig.new('spec/tmp/test/current').app_name.should == 'test'
  end
end
