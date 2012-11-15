require 'pathname'
require 'yaml'
require 'foreman'
require 'foreman/engine'
require 'thor/core_ext/hash_with_indifferent_access'
require 'god'

module ForemanGod
  class GodConfig
    attr_reader :dir_name, :options, :engine

    def initialize dir
      @dir_name = File.basename(File.absolute_path(dir))

      options_file = File.join(dir, ".foreman")
      temp_options = {}
      temp_options = (::YAML::load_file(options_file) || {}) if File.exists? options_file
      @options = Thor::CoreExt::HashWithIndifferentAccess.new(temp_options)


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
    end

    def app_name
      @options[:app] || @dir_name
    end

    def user_name
      @options[:user]
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
        w.start = process.expanded_command(env)
        w.log = "#{app_name}-#{name}-#{n}.log"  # TODO: make this folder configurable

        w.uid = user_name if user_name
        # w.gid = ?

        w.transition(:up, :restart) do |on|
          on.condition(:memory_usage) do |c|
            c.above = 350.megabytes
            c.times = 2
          end
        end

        # determine the state on startup
        w.transition(:init, { true => :up, false => :start }) do |on|
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


