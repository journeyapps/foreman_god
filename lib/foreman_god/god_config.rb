require 'pathname'
require 'yaml'
require 'foreman'
require 'foreman/engine'
require 'thor/core_ext/hash_with_indifferent_access'
require 'god'
require 'foreman_god'
require 'foreman_god/conditions'
require 'etc'

module God
  Watch::VALID_STATES << :stop unless Watch::VALID_STATES.include? :stop
end

module ForemanGod

  class GodConfig
    attr_reader :dir_name, :options, :engine

    # Defaults to the owner of Procfile, but may be overridden with the user option in .foreman
    attr_reader :user_name

    def initialize dir, override_options={}
      @dir_name = File.basename(File.absolute_path(dir))
      if @dir_name == 'current'
        @dir_name = File.basename(File.dirname(File.absolute_path(dir)))
      end

      options_file = File.join(dir, ".foreman")
      temp_options = {}
      temp_options = (::YAML::load_file(options_file) || {}) if File.exists? options_file
      @options = Thor::CoreExt::HashWithIndifferentAccess.new(temp_options)
      @options.merge! override_options


      @engine = Foreman::Engine.new(@options)

      if @options[:env]
        @options[:env].split(",").each do |file|
          @engine.load_env file
        end
      else
        default_env = File.join(dir, ".env")
        @engine.load_env default_env if File.exists?(default_env)
      end

      @engine.load_procfile(File.join(dir, "Procfile"))

      procfile_owner = Etc.getpwuid(File.stat(File.join(dir, "Procfile")).uid).name
      @user_name = @options[:user] || procfile_owner
    end

    def app_name
      @options[:app] || @dir_name
    end

    def log_path
      @options[:log] || 'log'
    end

    def group_name
      gid = Etc.getpwnam(user_name).gid
      Etc.getgrgid(gid).name
    end

    def file_dir(process)
      File.join(process.cwd, 'tmp')
    end

    def stop_file(process)
      File.join(file_dir(process), 'stop.txt')
    end

    def stop_file?(process)
      File.exists?(stop_file(process))
    end

    def restart_file(process)
      File.join(file_dir(process), 'restart.txt')
    end

    def wrap_command(cmd)
      if user_name
        user_home = File.join('/home', user_name)
      else
        user_home = Dir.home
      end
      local_rvm_version = @options[:user_rvm]
      system_rvm_version = @options[:system_rvm]
      auto_rvm = @options[:rvm]
      if auto_rvm
        if File.directory? File.join(user_home, '.rvm', 'environments')
          local_rvm_version = auto_rvm
        elsif File.directory? '/usr/local/rvm/environments'
          system_rvm_version = auto_rvm
        end
      end
      if local_rvm_version
        rvm_env = File.join(user_home, '.rvm', 'environments', local_rvm_version)
        ". #{rvm_env} && exec #{cmd}"
      elsif system_rvm_version
        rvm_env = File.join('/usr/local/rvm/environments', system_rvm_version)
        ". #{rvm_env} && exec #{cmd}"
      else
        cmd
      end
    end

    def watch_process(name, process, n)
      port = @engine.port_for(process, n)
      base_env = process.instance_variable_get(:@options)[:env]
      env = base_env.merge({'PORT' => port.to_s})

      God.watch do |w|
        w.dir = process.cwd
        w.name = "#{app_name}-#{name}-#{n}"
        w.group = app_name
        w.interval = 60.seconds
        w.env = env
        log = File.expand_path(log_path, process.cwd)
        if File.directory? log
          w.log = File.join(log, "#{app_name}-#{name}-#{n}.log")
        else
          LOG.warn "Log path does not exist: #{log}"
        end

        w.start = wrap_command(process.expanded_command(env))

        # Only set the uid if the user is different from the current user
        if user_name && (Etc.getpwuid(Process.uid).name != user_name)
          w.uid = user_name
          w.gid = group_name
        end

        w.transition(:up, :stop) do |stop|
          stop.condition(:foreman_stop_file_exists) do |c|
            c.interval = 5.seconds
            c.stop_file = stop_file(process)
          end
        end

        w.transition(:stop, :up) do |start|
          start.condition(:foreman_stop_file_exists) do |c|
            c.interval = 5.seconds
            c.invert = true # absence
            c.stop_file = stop_file(process)
          end
        end

        w.transition(:up, :restart) do |on|
          on.condition(:foreman_restart_file_touched) do |c|
            c.interval = 5.seconds
            c.restart_file = restart_file(process)
          end
        end

        # determine the state on startup
        w.transition(:init, { true => stop_file?(process) ? :stop : :up,
                             false => stop_file?(process) ? :stop : :start }
        ) do |on|
          on.condition(:process_running) do |c|
            c.running = true
          end
        end

        # determine when process has finished starting
        w.transition([:start, :restart], :up) do |on|
          on.condition(:process_running) do |c|
            c.running = true
            c.interval = 5.seconds
          end

          # failsafe
          on.condition(:tries) do |c|
            c.times = 5
            c.transition = :start
            c.interval = 5.seconds
          end
        end

        # start if process is not running
        w.transition(:up, :start) do |on|
          on.condition(:process_running) do |c|
            c.running = false
          end
        end
      end
    end

    def watch
      @engine.each_process do |name, process|
        1.upto(@engine.formation[name]) do |n|
          watch_process name, process, n
        end
      end
    end
  end
end

