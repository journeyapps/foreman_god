# ForemanGod

Monitor Procfiles with [God](http://godrb.com/).

## Installation

Install the gem on the machine running god - there is no need to include it as a dependency in your project.

    $ gem install foreman_god

## Usage

To run the sample:

    god -D -c sample.god

Or with your own Procfile, add the following to your god configuration file:

    require 'foreman_god'

    ForemanGod.watch File.dirname(__FILE__) # Or an absolute path to the folder containing the Procfile

To set environment variables, add an .env file in next to the Procfile.

To specify foreman options, add a .foreman file next to the Procfile.

See samples/configuration for a complete example.

### Restarting workers

If present, the `tmp/restart.txt` file in your project is watched for changes. If this file is modified, for example
with `touch tmp/restart.txt`, all workers are restarted.

### Stop workers

If present, the `tmp/stop.txt` file will stop all workers.  If it is removed, the workers will start.

### Reloading the Procfile

When the Procfile (or .env or .foreman files) changed, use `god load <god config> stop` to reload the config files.
The `stop` action tells god to stop any processes that were removed from the Procfile (available since god 0.12.0,
but not documented at the time of writing).

### RVM

To run god itself with RVM, use a wrapper script as explained at [https://rvm.io/integration/god/](https://rvm.io/integration/god/).

Using RVM is tricky when running God as root. Often you would want to run the commands in a different environment from
god (different user, different Ruby, different gems, etc).

The simplest way to tell ForemanGod to run your processes with RVM, is to specify `rvm: default` in your .foreman config
file. This tells ForemanGod to use the "default" Ruby version to run the script. Alternatively you can specify a
specific ruby version or gemset, for example `rvm: ruby-1.9.3-p194` or `rvm: ruby-1.9.3-p194@global`.

Technically this loads the environment for the ruby/gemset version, which is found in either `~/.rvm/environments/<version>`
or `/usr/local/rvm/<version>`. This is similar to the approach for [Cron scripts](https://rvm.io/integration/cron/).

### Capistrano

On each deployment, God needs to reload the configuration. Restarting of the processes happen with the `tmp/restart.txt`
solution explained earlier, which you already do if you're using Passenger.

Use a task like the following to reload the configuration (see *Reloading the Procfile* above):

    namespace :god do
      task :reload do
        # Replace the god command and config file here with the ones used on your server
        run("god load /etc/god/master.god stop")
      end
    end

    before "deploy:restart", "god:reload"




## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
