require "rspec"
require "capybara/rspec"

ENV['RACK_ENV'] = 'test'

require File.expand_path "../../lib/application", __FILE__
require File.expand_path "../../lib/interactiveshell", __FILE__

s = NBlog::InteractiveShell.new [], false
s.parse "init"
s.parse "add-user test secret"

Capybara.app = NBlog::Application
Capybara.ignore_hidden_elements = false

RSpec.configure do |c|
  c.include Capybara::DSL
end