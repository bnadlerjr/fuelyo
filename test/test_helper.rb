ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'factory_girl'
require  File.join(File.dirname(__FILE__), 'factories')
require 'fuelyo'

def reset_database
  FuelRecord.destroy
  User.destroy
end
