# Frank

<a href="https://codeclimate.com/github/ganmacs/frank"><img src="https://codeclimate.com/github/ganmacs/frank/badges/gpa.svg" /></a>
[![Build Status](https://travis-ci.org/ganmacs/frank.svg)](https://travis-ci.org/ganmacs/frank)

Frank is DSL for creating web applications inspired by Sinatra.

## Usage

```rb
require 'frank'

class App < Frank::Base
  before do
    @config = {
      name: 'sample_app'
    }
  end

  get '/' do
    'root'
  end

  get '/user/:name' do |name|
    name
  end

  post '/message' do
    params[:body]
  end

  get '/app_name' do
    @config['name']
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
