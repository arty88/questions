require 'rails_helper'

describe 'Answers API', type: :request do
  describe 'GET /index' do
    let!(:question) { create(:question) }
    let(:http_method) { :get }
    let(:url) { api_v1_question_answers_path(question_id: question.id) }

    it_behaves_like "API unauthorized"

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let!(:answers) { create_list(:answer, 2, question: question) }
      let(:answer) { answers.first }

      before { do_request(http_method, url, { access_token: access_token.token }) }

      it 'returns 200 status code' do
        expect(response).to be_success
      end

      it 'returns list of answers' do
        expect(response.body).to have_json_size(2).at_path('answers')
      end

      %w(id body created_at updated_at author_id question_id).each do |attr|
        it "answer object contains #{attr}" do
          expect(response.body).to be_json_eql(answer.send(attr.to_sym).to_json).at_path("answers/0/#{attr}")
        end
      end
    end
  end

  describe 'GET /show' do
    let!(:answer) { create(:answer) }
    let(:http_method) { :get }
    let(:url) { api_v1_answer_path(answer) }

    it_behaves_like "API unauthorized"

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let!(:comment) { create(:comment, commentable: answer) }
      let!(:attachment) { create(:attachment, attachable: answer) }
      let(:json_root_path) { "answer" }

      before { do_request(:get, url, { access_token: access_token.token }) }

      it 'returns 200 status code' do
        expect(response).to be_success
      end

      it 'returns answer' do
        expect(response.body).to have_json_path('answer')
      end

      %w(id body created_at updated_at author_id question_id).each do |attr|
        it "answer object contains #{attr}" do
          expect(response.body).to be_json_eql(answer.send(attr.to_sym).to_json).at_path("answer/#{attr}")
        end
      end

      it_behaves_like "API comments"
      it_behaves_like "API attachments"
    end
  end

  describe 'POST /create' do
    let!(:question) { create(:question) }
    let(:http_method) { :post }
    let(:url) {  "/api/v1/questions/#{question.id}/answers" }

    it_behaves_like "API unauthorized"

    context 'authorized' do
      let(:access_token) { create(:access_token) }

      context 'with valid answer params' do
        before { do_request(http_method, url, { answer: attributes_for(:answer), access_token: access_token.token }) }

        it 'returns 201 status code' do
          expect(response).to have_http_status 201
        end

        it 'returns created answer' do
          expect(response.body).to have_json_path('answer')
        end

        it "answer object contains body" do
          expect(response.body).to be_json_eql(attributes_for(:answer)[:body].to_json).at_path("answer/body")
        end
      end

      context 'with invalid answer params' do
        before { do_request(:post, url, { answer: attributes_for(:invalid_answer), access_token: access_token.token }) }

        it "returns 422 status code" do
          expect(response).to have_http_status 422
        end

        it 'returns errors list' do
          expect(response.body).to have_json_size(1).at_path('errors')
        end

        it 'returns body presence error' do
          expect(response.body).to be_json_eql("can't be blank".to_json).at_path("errors/body/0")
        end

        it "returns body length error" do
          expect(response.body).to be_json_eql("is too short (minimum is 10 characters)".to_json).at_path("errors/body/1")
        end
      end
    end
  end
end
