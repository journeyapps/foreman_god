require 'foreman_god'

ForemanGod.log_path = File.join(File.dirname(__FILE__), 'tmp')
puts ForemanGod.log_path.inspect
puts File.join(File.dirname(__FILE__), '..', 'samples', 'simple').inspect
ForemanGod.watch File.join(File.dirname(__FILE__), '..', 'samples', 'simple')
