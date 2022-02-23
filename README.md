# Choria::Colt

This _gem_ provides:
 * `colt` executable, a [Bolt](https://puppet.com/docs/bolt/latest/bolt.html)-like command line interface to run _Bolt_ task through [Choria](https://puppet.com/docs/bolt/latest/bolt.html)
 * helpers functions and classes to run _Bolt_ tasks through _Choria_ infrastructure from any _ruby_ code

## Usage

### CLI

```shell-session
$ colt tasks run exec=hostname -t vm012345.example.net,vm543210.example.net
```

### Code

```ruby
require 'choria/colt'

targets = [ 'vm012345.example.net' ]
task_name = 'exec'
task_input = { 'command' => 'hostname' }

colt = Choria::Colt.new(logger: Logger.new($stdout))
results = colt.run_bolt_task task_name, input: task_input, targets: targets

$stdout.puts JSON.pretty_generate(results)
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'choria-colt'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install choria-colt

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/opus-codium/choria-colt.
