require 'rails_helper'

RSpec.describe '/articles routes' do
  it 'should get routee to articles#index' do
    aggregate_failures do
      expect(get '/articles').to route_to('articles#index')
      expect(get '/articles?page[number]=3').to (route_to('articles#index', page: {"number"=>"3"}))
    end
  end

  it 'should get route to articles#show' do
    expect(get '/articles/1').to route_to('articles#show', id: "1")
  end

  it 'should get route to articles#create' do
    expect(post '/articles').to route_to('articles#create')
  end

  it 'should get route to articles#update' do
    expect(put '/articles/1').to route_to('articles#update', id: "1")
    expect(patch '/articles/1').to route_to('articles#update', id: "1")
  end

  it 'should get route to articles#destroy' do
    expect(delete '/articles/1').to route_to('articles#destroy', id: "1")
  end


end