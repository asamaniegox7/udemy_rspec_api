require 'rails_helper'

RSpec.describe CommentsController, type: :controller do

  let(:article) {create :article}

  describe "GET /index" do

    subject {get :index, params: {article_id: article.id} }

    it "renders a successful response" do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should only return comments belonging to an article' do
      comment = create :comment, article: article
      create :comment
      subject
      expect(json_data.length).to eq(1)
      expect(json_data.first[:id]).to eq(comment.id.to_s)
    end

    it 'should paginate results' do
      comments = create_list :comment, 3, article: article
      get :index, params: { article_id: article.id, page: {number: 2, size: 1} }
      expect(json_data.length).to eq(1)
      comment = comments.second
      expect(json_data.first[:id]).to eq(comment.id.to_s)
    end

    it 'should have proper json body' do
      comment = create :comment, article: article
      subject
      expect(json_data.first[:attributes][:content]).to eq(comment.content)
    end

    it 'should have related objects in the response' do
      user = create :user
      comment = create :comment, article: article, user: user
      subject
      relationships = json_data.first[:relationships]
      expect(relationships[:article][:data][:id]).to eq(article.id.to_s)
      expect(relationships[:user][:data][:id]).to eq(user.id.to_s)
    end

  end

  describe "POST /create" do

    context 'when unauthorized' do
      subject {post :create, params: {article_id: article.id}}
      it_behaves_like "forbidden_requests"
    end

    context 'when authorized' do
      let(:valid_attributes) do
        { data: { attributes: {content: 'My awesome comment for an article.'}}}
      end
      
      let(:invalid_attributes)do
        { data: { attributes: {content: ''}}}
      end

      let(:user) {create :user}
      let(:access_token){ user.create_access_token}
      before { request.headers['authorization'] = "Bearer #{access_token.token}"}

      context "with valid parameters" do
        subject {
          post :create, params: valid_attributes.merge(article_id: article.id)
        }

        it 'returns 201 status code' do
          subject
          expect(response).to have_http_status(:created)
        end

        it "creates a new Comment" do
          expect { subject }.to change(Comment, :count).by(1)
        end

        it "renders a JSON response with the new comment" do
          subject
          expect(json[:content]).to eq('My awesome comment for an article.')
        end
      end

      context "with invalid parameters" do
        subject {
          post :create, params: invalid_attributes.merge(article_id: article.id)
        }

        it "does not create a new Comment" do
          expect{ subject }.to change(Comment, :count).by(0)
        end

        it "should return 422 status code" do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "renders a JSON response with errors for the new comment" do
          subject
          expect(json[:errors]).to include(
          {
            :source => { pointer: "/data/attributes/content" },
            :detail => "can't be blank"
          })
        end
      end
    end
  end

end
