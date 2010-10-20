class User
  include DataMapper::Resource

  property :id, Serial
  property :provider, String
  property :auth_provider_uid, Integer
  property :name, String

  has n, :fuel_records

  def self.find_by_zeep_mobile_uid(uid)
    User.first(:zeep_mobile_uid.eql => uid)
  end

  def self.find_or_create_by_auth_info(auth)
    user = User.first(:auth_provider_uid.eql => auth['uid'])
    unless user
      user = User.new(
        :provider => auth['provider'],
        :auth_provider_uid => auth['uid'],
        :name => auth['user_info']['name']
      )
      user.save
    end

    user
  end

  def fuel_history
    FuelRecord.history(self.id)
  end
end
