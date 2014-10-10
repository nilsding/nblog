require "rspec"
require "capybara/rspec"

require File.expand_path "../../lib/application", __FILE__

ENV['RACK_ENV'] = 'test'

Capybara.app = NBlog::Application
Capybara.ignore_hidden_elements = false

RSpec.configure do |c| 
  c.include Capybara::DSL
end