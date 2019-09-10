# Deribit

# API Client for v2 [Deribit API](https://docs.deribit.com/v2/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'deribit-v2'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install deribit-v2

## Usage


### Example

```
require 'deribit-v2'

# main server
api = Deribit::API.new("KEY", "SECRET")
# test server
api = Deribit::API.new("KEY", "SECRET", test_server: true)

api.get_index currency: "BTC"
api.get_account_summary currency: "BTC"
```

### Methods

A full list of availiable methods are here:
https://docs.deribit.com/v2/

## Websocket API

```
require 'deribit-v2'

ws = Deribit::WS.new("KEY", "SECRET")
ws.connect

# set heartbeat to prevent disconnection
ws.set_heartbeat interval: 120

# example of request: 
ws.get_account_summary currency: "BTC"

# example of subscription
ws.subscribe channels: ["deribit_price_index.btc_usd"]
```

### Example: custom handler for subscription events

Create inheritance class for handling WS notifications

```
class MyHandler < Deribit::WS::Handler
  # event handler
  def subscription(json)
    # your actions here
  end
end

api = Deribit::API.new("KEY", "SECRET", handlers: [MyHandler.new])
```


Available events you can check in the guide https://docs.deribit.com/v2/ WebSockets API section.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/v1z4/deribit-ruby-v2. This project is intended to be a safe, welcoming space for collaboration. 