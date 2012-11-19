require "foreman_god/version"
require "foreman_god/god_config"

module ForemanGod
  def self.log_path= path
    @log_path = path
  end

  def self.log_path
    @log_path
  end

  # ForemanGod.watch File.dirname(__FILE__) => calls God.watch with the Procfile in the current file's folder
  def self.watch dir
    config = GodConfig.new(dir)
    config.watch
    config
  end
end

