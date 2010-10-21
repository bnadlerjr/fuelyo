Factory.define :fuel_record do |f|
  f.odometer 100
  f.price 0.99
  f.gallons 12
  f.association :user, :factory => :user
end

Factory.define :user do |f|
  f.name 'JohnDoe'
end
