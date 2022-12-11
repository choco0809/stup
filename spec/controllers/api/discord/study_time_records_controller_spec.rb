# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Discord::StudyTimeRecordsController, type: :controller do
  describe 'create' do
    let(:user) { FactoryBot.build(:user, uid: '1234567') }
    context 'ユーザーが未登録の場合' do
      it 'ユーザーが未登録の場合、学習記録は作成されないこと' do
        post :create, params: {
          uid: user.uid,
          started_at: '2022/12/11 15:00:00'
        }
        expect(response).to have_http_status '200'
        expect(response.parsed_body['message']).to eq 'ユーザーが未登録です'
        expect(StudyTimeRecord.count).to eq 0
      end
    end

    context 'ユーザーが登録されている場合' do
      let!(:user) { FactoryBot.create(:user, uid: '1234567') }
      it '学習記録が存在しない場合、学習記録が作成されること' do
        post :create, params: {
          uid: user.uid,
          started_at: '2022/12/11 15:00:00'
        }
        record = StudyTimeRecord.find_by(user_id: user.id)
        expect(response).to have_http_status '200'
        expect(response.parsed_body['message']).to eq '学習の記録を開始しました'
        expect(StudyTimeRecord.find(record.id).started_at).to eq '2022-12-11 15:00:00.000000000 +0900'
        expect(StudyTimeRecord.count).to eq 1
      end

      it '前回の学習記録が終了されていない場合、新規で学習記録が作成されないこと' do
        # 1回目の学習を登録する
        post :create, params: {
          uid: user.uid,
          started_at: '2022/12/11 15:00:00'
        }

        # 2回目の学習を登録する（※ 登録されない）
        post :create, params: {
          uid: user.uid,
          started_at: '2022/12/11 18:00:00'
        }

        expect(response).to have_http_status '200'
        expect(response.parsed_body['message']).to eq '前回の学習記録が終了していません'
        expect(StudyTimeRecord.count).to eq 1
      end
    end
  end

  describe 'update' do
    context 'ユーザーが未登録の場合、学習記録は作成されないこと' do
      let(:user) { FactoryBot.build(:user, uid: '1234567') }
      it 'ユーザーが未登録の旨のメッセージが返ってくること' do
        patch :update, params: {
          uid: user.uid,
          ended_at: '2022/12/11 15:00:00'
        }
        expect(response).to have_http_status '200'
        expect(response.parsed_body['message']).to eq 'ユーザーが未登録です'
        expect(StudyTimeRecord.count).to eq 0
      end
    end

    context 'ユーザーが登録されている場合' do
      let!(:user) { FactoryBot.create(:user, uid: '1234567') }
      it '学習が開始されていない場合、学習記録は作成されないこと' do
        patch :update, params: {
          uid: user.uid,
          ended_at: '2022/12/11 15:00:00'
        }
        expect(response).to have_http_status '200'
        expect(response.parsed_body['message']).to eq '学習が開始されていません'
        expect(StudyTimeRecord.count).to eq 0
      end

      it '学習が開始されていた場合、ended_atが更新されること' do
        # 学習記録を作成する
        post :create, params: {
          uid: user.uid,
          started_at: '2022/12/11 15:00:00'
        }
        record = StudyTimeRecord.find_by(user_id: user.id)

        expect(response).to have_http_status '200'
        expect(response.parsed_body['message']).to eq '学習の記録を開始しました'

        # 学習記録を終了する
        patch :update, params: {
          uid: user.uid,
          ended_at: '2022/12/11 16:00:00'
        }

        expect(response).to have_http_status '200'
        expect(response.parsed_body['message']).to eq '学習が終了しました'
        expect(StudyTimeRecord.find(record.id).ended_at).to eq '2022-12-11 16:00:00.000000000 +0900'
      end
    end
  end
end
