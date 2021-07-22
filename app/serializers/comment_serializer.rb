class CommentSerializer
  include JSONAPI::Serializer
  set_type :comments
  attributes :id, :content
  has_one :article
  has_one :user, serializer: 'User'
end
