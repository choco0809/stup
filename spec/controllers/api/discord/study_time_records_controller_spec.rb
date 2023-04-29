# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Discord::StudyTimeRecordsController, type: :controller do

  STUP_URL = 'https://stup.fly.dev/'
  UNREGISTERED_USER = "ユーザーが登録されていません。\n下記のURLからユーザー登録を行った後、再度実行して下さい🙇\n#{STUP_URL}".freeze
  START_REPORT = '学習の記録を開始しました🙆'
  FINISH_REPORT = '学習が終了しました🙆'
  INCOMPLETE_REPORT = '前回の学習記録が終了していません🙅'
  NOT_STARTED = "学習が開始されていません。\n学習の記録を開始してください🙇"
  OVER_24_HOURS = "前回の学習記録から24時間以上経過しています。\n下記のURLから手動にて終了時間を記入して下さい🙇\n#{STUP_URL}".freeze

  describe 'create' do
    let(:user) { FactoryBot.build(:user, uid: '1234567') }
    context 'ユーザーが未登録の場合' do
      it 'ユーザーが未登録の場合、学習記録は作成されないこと' do
        post :create, params: {
          uid: user.uid,
          started_at: '2022/12/11 15:00:00'
        }
        expect(response).to have_http_status '200'
        expect(response.parsed_body['message']).to eq UNREGISTERED_USER
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
        expect(response.parsed_body['message']).to eq START_REPORT
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
        expect(response.parsed_body['message']).to eq "#{INCOMPLETE_REPORT}\n2022/12/11 15:00"
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
        expect(response.parsed_body['message']).to eq UNREGISTERED_USER
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
        expect(response.parsed_body['message']).to eq NOT_STARTED
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
        expect(response.parsed_body['message']).to eq START_REPORT

        # 学習記録を終了する
        patch :update, params: {
          uid: user.uid,
          ended_at: '2022/12/11 16:00:00'
        }

        expect(response).to have_http_status '200'
        expect(response.parsed_body['message']).to eq FINISH_REPORT
        expect(StudyTimeRecord.find(record.id).ended_at).to eq '2022-12-11 16:00:00.000000000 +0900'
      end

      it '前回の学習記録から、終了時間が24時間以上経過している場合は手動にて終了時間を記入するようにリプライされること' do
        # 学習記録を作成する
        post :create, params: {
          uid: user.uid,
          started_at: '2022/12/11 15:00:00'
        }
        record = StudyTimeRecord.find_by(user_id: user.id)

        expect(response).to have_http_status '200'
        expect(response.parsed_body['message']).to eq START_REPORT

        # 学習記録を終了する（※更新されない）
        patch :update, params: {
          uid: user.uid,
          ended_at: '2022/12/13 16:00:00'
        }

        expect(response).to have_http_status '200'
        expect(response.parsed_body['message']).to eq OVER_24_HOURS
        expect(StudyTimeRecord.find(record.id).ended_at).to eq nil
      end
    end
  end
end
