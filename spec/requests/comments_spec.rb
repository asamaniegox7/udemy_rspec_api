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
      #expected_article = Article.recent.second.id.to_s
      #expect(json_data.first['id']).to eq(expected_article)
    end

    it 'should have proper json body' do
      comment = create :comment, article: article
      subject
      expect(json_data.first[:attributes][:content]).to eq(comment.content)
    end

  end

  describe "POST /create" do
    let(:valid_attributes) {{content: 'My awesome comment for an article.'}}
    let(:invalid_attributes) {{content: ''}}

    context 'when unauthorized' do
      subject {post :create, params: {article_id: article.id}}
      it_behaves_like "forbidden_requests"
    end

    context 'when authorized' do
      let(:user) {create :user}
      let(:access_token){ user.create_access_token}
      before { request.headers['authorization'] = "Bearer #{access_token.token}"}

      context "with valid parameters" do
        it "creates a new Comment" do
          expect {
            post :create,
                 params: { article_id: article.id, comment: valid_attributes }
          }.to change(Comment, :count).by(1)
        end

        it "renders a JSON response with the new comment" do
          post :create,
               params: { comment: valid_attributes, article_id: article.id }
          expect(response).to have_http_status(:created)
          expect(response.location).to eq(article_url(article))
          expect(response.content_type).to match(a_string_including("application/json"))
        end
      end

      context "with invalid parameters" do
        it "does not create a new Comment" do
          expect {
            post :create,
                 params: { article_id: article.id, comment: invalid_attributes }
          }.to change(Comment, :count).by(0)
        end

        it "renders a JSON response with errors for the new comment" do
          post :create,
               params: { article_id: article.id, comment: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq("application/json; charset=utf-8")
        end
      end
    end
  end

end
