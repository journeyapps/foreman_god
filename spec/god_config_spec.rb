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
      config.user_name.should == nil
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
      watch.log.should == 'simple-loop-1.log'
      watch.uid.should == nil

    end


  end

  context "configuration" do
    let(:config) { GodConfig.new(sample('configuration')) }
    let(:user) { Etc.getlogin }
    it "should load basic properties" do
      config.dir_name.should == 'configuration'
      config.app_name.should == 'configured-app'
      config.user_name.should == 'test'
      config.options.should ==  {"formation"=>"loop=1,another=2", "app"=>"configured-app", "user"=>"test"}
    end

    it "should watch" do
      config.options["user"] = user # We need to override the user to the current user, otherwise god will fail

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
      watch.log.should == 'configured-app-loop-1.log'
      watch.uid.should == user
    end


  end

end
