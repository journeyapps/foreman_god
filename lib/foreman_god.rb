require "foreman_god/version"
require "foreman_god/god_config"

module ForemanGod

  # ForemanGod.watch File.dirname(__FILE__) => calls God.watch with the Procfile in the current file's folder
  # ForemanGod.watch '/var/www/*/current/' => watch all folders matching the glob which contain either a .foreman file or a
  #   Procfile.
  def self.watch glob
    # We append a backslash so that only folders are matched
    glob += '/' unless glob.end_with? '/'
    Dir[glob].each do |d|
      if File.exists?(File.join(d, 'Procfile')) || File.exists?(File.join(d, '.foreman'))
        watch_dir d
      end
    end
  end

  def self.watch_dir dir
    config = GodConfig.new(dir)
    config.watch
    config
  end
end

