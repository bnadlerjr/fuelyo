class User
  include DataMapper::Resource

  property :id, Serial
  property :provider, String
  property :auth_provider_uid, Integer
  property :zeep_mobile_uid, Integer
  property :name, String

  has n, :fuel_records

  def self.find_by_zeep_mobile_uid(uid)
    User.first(:zeep_mobile_uid.eql => uid)
  end
end
