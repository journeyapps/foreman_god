require 'rspec'
$load_god = true
require 'god'
require 'foreman_god'

LOG_FILE = 'god.log'
FileUtils.rm_r LOG_FILE

Object.send(:remove_const, :LOG)
LOG = God::Logger.new(File.open(LOG_FILE, 'w'))

include ForemanGod

def sample(name)
  File.absolute_path(File.join(File.dirname(__FILE__), '..', 'samples', name))
end


module God

  def self.reset
    self.watches = nil
    self.groups = nil
    self.server = nil
    self.inited = nil
    self.host = nil
    self.port = nil
    self.pid_file_directory = File.join(File.dirname(__FILE__), 'tmp')
    self.registry.reset
  end
end


RSpec.configure do |config|
  #Other config stuff goes here

  # Clean/Reset God's state prior to running the tests
  config.before :each do
    God.reset
    FileUtils.rm_rf 'spec/tmp'
    FileUtils.mkdir_p 'spec/tmp'
  end

  config.after :each do
    FileUtils.rm_rf 'spec/tmp'
  end
end
