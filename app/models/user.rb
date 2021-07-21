class User < ApplicationRecord
  validates :login, :provider, presence: true
  validates :login, uniqueness: true

  has_one :access_token, dependent: :destroy
  has_many :articles, dependent: :destroy
end
