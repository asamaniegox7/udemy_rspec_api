require 'rails_helper'

RSpec.describe 'access tokens routes' do
  it 'should route to access_token create actions' do
    expect(post '/login').to route_to('access_tokens#create')
  end

  it "should route to access_tokens destroy actions" do
    expect(delete '/logout').to route_to('access_tokens#destroy')
  end

end
