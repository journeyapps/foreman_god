# ForemanGod

God configuration with Procfiles.

## Installation

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
