require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do

  describe '#index' do
    subject { get :index }

    it 'should return success response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper json' do
      create_list :article, 2
      subject
      Article.recent.each_with_index do |article, index|
        expect(json[:data][index][:attributes]).to eq({
          title: article.title,
          content: article.content,
          slug: article.slug
        })
      end
    end

    it 'should return articles in the proper order' do
      old_article = create :article
      newer_article = create :article
      subject
      expect(json[:data].first[:id]).to eq(newer_article.id.to_s)
      expect(json[:data].last[:id]).to eq(old_article.id.to_s)
    end

  end

  describe '#show' do
    let(:article) {create :article}
    subject { get :show, params: {id: article.id}}

    it 'should return a proper response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper json' do
      subject
      expect(json_data[:attributes]).to eq(
        title: article.title,
        content: article.content,
        slug: article.slug
      )
    end
  end

  describe '#create' do

    subject {post :create}

    context 'when no code is provided' do
      it_behaves_like "forbidden_requests"
    end

    context 'when invalid code is provided' do
      before {request.headers['authorization'] = 'Invalid Token'}
      it_behaves_like "forbidden_requests"
    end

    context 'when authorized' do

      let(:user) {create :user}
      let(:access_token){ user.create_access_token}
      before { request.headers['authorization'] = "Bearer #{access_token.token}"}

      context 'when invalid parameters are provided' do

        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '',
                content: ''
              }
            }
          }
        end

        subject {post :create, params: invalid_attributes}

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return proper json error' do
          subject
          expect(json[:errors]).to include(
          {
            :source => { pointer: "/data/attributes/title" },
            :detail => "can't be blank"
          },
          {
            :source => { pointer: "/data/attributes/content" },
            :detail => "can't be blank"
          },
          {
            :source => { pointer: "/data/attributes/slug" },
            :detail => "can't be blank"
          })
        end
      end

      context 'when success request sent' do

        let(:valid_attributes) do
          {
            data: {
              attributes: {
                title: 'Awesome title.',
                content: 'Super content.',
                slug: 'awesome-article'
              }
            }
          }
        end

        subject {post :create, params: valid_attributes}

        it 'should return a 201 status code' do
          subject
          expect(response).to have_http_status(:created)
        end

        it 'should have proper json body' do
          subject
          expect(json).to include(valid_attributes[:data][:attributes])
        end

        it 'should create the article' do
          expect{ subject }.to change{ Article.count }.by(1)
        end

      end
    end

  end

  describe '#update' do

    let(:user) {create :user}
    let(:article) {create :article, user: user}
    let(:access_token){ user.create_access_token}

    subject {patch :update, params: {id: article.id}}

    context 'when no code is provided' do
      it_behaves_like "forbidden_requests"
    end

    context 'when invalid code is provided' do
      before {request.headers['authorization'] = 'Invalid Token'}
      it_behaves_like "forbidden_requests"
    end

    context 'when updating unauthorized article' do
      let(:other_user) { create :user}
      let(:other_article) {create :article, user: other_user}

      subject { patch :update, params: {id: other_article.id}}

      before {request.headers['authorization'] = "Bearer #{access_token.token}"}
      it_behaves_like "forbidden_requests"
    end

    context 'when authorized' do
      before { request.headers['authorization'] = "Bearer #{access_token.token}"}

      context 'when invalid parameters are provided' do

        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '',
                content: ''
              }
            }
          }
        end

        subject {put :update, params: invalid_attributes.merge({id: article.id})}

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return proper json error' do
          subject
          expect(json[:errors]).to include(
          {
            :source => { pointer: "/data/attributes/title" },
            :detail => "can't be blank"
          },
          {
            :source => { pointer: "/data/attributes/content" },
            :detail => "can't be blank"
          })
        end
      end

      context 'when success request sent' do

        let(:valid_attributes) do
          {
            data: {
              attributes: {
                title: 'Awesome title.',
                content: 'Super content.',
                slug: 'awesome-article'
              }
            }
          }
        end

        subject {put :update, params: valid_attributes.merge(id: article.id)}

        it 'should return an ok status code' do
          subject
          expect(response).to have_http_status(:ok)
        end

        it 'should have proper json body' do
          subject
          expect(json).to include(valid_attributes[:data][:attributes])
        end

        it 'should update the article' do
          subject
          expect(article.reload.title).to eq(
            valid_attributes[:data][:attributes][:title]
          )
        end

      end
    end

  end

  describe '#destroy' do

    let(:user) {create :user}
    let(:article) {create :article, user: user}
    let(:access_token){ user.create_access_token}

    subject { delete :destroy, params: {id: article.id} }

    context 'when no authorization header is provided' do
      it_behaves_like "forbidden_requests"
    end

    context "when invalid authorization header is provided" do
      before { request.headers['authorization'] = 'Invalid token'}
      it_behaves_like "forbidden_requests"
    end

    context 'when updating unauthorized article' do
      let(:other_user) { create :user}
      let(:other_article) {create :article, user: other_user}

      subject { delete :destroy, params: {id: other_article.id}}

      before {request.headers['authorization'] = "Bearer #{access_token.token}"}
      it_behaves_like "forbidden_requests"
    end

    context 'when valid request' do

      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      it "should return 204 status code" do
        subject
        expect(response).to have_http_status(:no_content)
      end

      it 'should have empty json body' do
        subject
        expect(response.body).to be_blank
      end

      it "should remove the article" do
        article #subject creates and removes article simultaneosly, so unless we
        #create the article beforehand, the count will not be changed
        expect{ subject }.to change{ user.articles.count }.by(-1)
      end

    end
  end

end
