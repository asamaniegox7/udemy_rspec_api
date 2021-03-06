require 'rails_helper'

shared_examples_for "unauthorized requests" do

  let(:authentication_error) do
    {
      :status => "401",
      :source => { "pointer": "/code" },
      :title  => "Invalid Authentication Code",
      :detail => "Valid code must be provided in order to de exchanged for token."
    }
  end

  it "should return 401 status code" do
    subject
    expect(response).to have_http_status(401)
  end

  it "should return proper error body" do
    subject
    expect(json[:errors]).to include(authentication_error)
  end

end

shared_examples_for "forbidden_requests" do

  let(:forbidden_error) do
    {
      :status => "403",
      :source => { "pointer": "/headers/authorization" },
      :title  => "Forbidden",
      :detail => "User is not authorized to perform this action."
    }

    it 'should return 403 status code' do
      subject
      expect(response).to have_http_status(:forbidden)
    end

    it 'should return proper error body' do
      subject
      expect(json[:errors]).to eq(forbidden_error)
    end

  end

end
