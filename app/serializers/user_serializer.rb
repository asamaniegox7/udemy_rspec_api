class UserSerializer
  include JSONAPI::Serializer
  set_type :users
  attributes :id, :login, :name, :url, :avatar_url
end
