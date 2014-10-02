require "rspec"
require "capybara"
require "capybara/dsl"
# require "capybara/rspec"
require "rack/test"

require File.expand_path "../../app.rb", __FILE__

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end
end

Capybara.app = Sinatra::Application

RSpec.configure do |c| 
  c.include RSpecMixin
  c.include Capybara::DSL
end

$config['dbfile'] = "test.db"
