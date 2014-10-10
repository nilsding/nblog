require "rspec"
require "capybara"
require "capybara/dsl"
# require "capybara/rspec"
require "rack/test"

require File.expand_path "../../lib/application", __FILE__

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  
  def app
    NBlog::Application
  end
end

Capybara.app = NBlog::Application

RSpec.configure do |c| 
  c.include RSpecMixin
  c.include Capybara::DSL
end
