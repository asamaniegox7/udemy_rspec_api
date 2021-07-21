require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  describe '#validations' do
    it 'should have valid factory' do
      access_token = build :access_token
      expect(access_token).to be_valid
    end

    it 'should validate token' do
      access_token = build :access_token, token: nil, user: nil
      expect(access_token).not_to be_valid
      expect(access_token.errors.messages[:user]).to include("can't be blank")
      expect(access_token.errors.messages[:token]).to include("can't be blank")
    end

    it 'should validate uniqueness of token' do
      token1 = create(:access_token)
      expect(token1).to be_valid
      token2 = build(:access_token, token: token1.token)
      expect(token2).not_to be_valid
      expect(token2.errors[:token]).to include("has already been taken")
    end
  end

  describe "#new" do
    it "should have token present after initialization" do
      expect(AccessToken.new.token).to be_present
    end

    it "should generate a unique token" do
      user = create :user
      expect { user.create_access_token }.to change{ AccessToken.count }.by(1)
      expect(user.build_access_token).to be_valid
    end

    it "should generate the token once" do
      user = create :user
      access_token = user.create_access_token
      expect(access_token.token).to eq(access_token.reload.token)
    end
  end
end
