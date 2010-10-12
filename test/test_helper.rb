require 'rubygems'
require 'datamapper'
require 'models/fuel_record'

DataMapper::setup(:default, 'sqlite::memory:')

FuelRecord.auto_migrate!
