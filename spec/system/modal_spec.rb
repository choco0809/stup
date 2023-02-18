# frozen_string_literal: true

require 'rails_helper'
require 'capybara/rspec'

RSpec.describe 'Modal', type: :system do
  let!(:user) { FactoryBot.create(:user) }

  before do
    OmniAuth.config.mock_auth[:discord] = nil
    Rails.application.env_config['omniauth.auth'] = discord_oauth(user[:uid], user[:image])
  end

  describe 'モーダルウィンドウのテスト' do
    before do
      @current_user = User.find_by(uid: user.uid)
      StudyTimeRecord.create(
        user_id: @current_user.id,
        started_at: '2022-12-16 20:26:00',
        ended_at: '2022-12-16 21:26:00',
        memo: ''
      )
    end

    it 'カレンダーに表示されている学習時間をクリックすると、モーダルウィンドウが表示されること' do
      visit root_path
      click_on '学習を記録する'
      visit '/?calendar=2022-12'
      expect(page.all('.study-time')[15]).to have_content '60分'
      click_on '60分'
      within all('.modal-thread-list-item')[0] do
        expect(page.all('.modal-thread-list-contents')[0]).to have_content '20:26'
        expect(page.all('.modal-thread-list-contents')[1]).to have_content '21:26'
        expect(page.all('.modal-thread-list-contents')[2]).to have_content '60分'
      end
    end

    it '削除ボタンをクリックすると対象の学習記録が削除され、モーダルウィンドウが閉じられること' do
      visit root_path
      click_on '学習を記録する'
      visit '/?calendar=2022-12'
      expect(page.all('.study-time')[15]).to have_content '60分'
      click_on '60分'
      within all('.modal-thread-list-item')[0] do
        expect(page.all('.modal-thread-list-contents')[0]).to have_content '20:26'
        expect(page.all('.modal-thread-list-contents')[1]).to have_content '21:26'
        expect(page.all('.modal-thread-list-contents')[2]).to have_content '60分'
        find('button[data-method="delete"]').click
      end
      expect(page.all('.study-time')[15]).to have_content 'ー'
    end

    it 'ハイフンをクリックした時に表示されるモーダルウィンドウには学習記録が表示されないこと' do
      visit root_path
      click_on '学習を記録する'
      visit '/?calendar=2022-12'
      expect(page.all('.study-time')[0]).to have_content 'ー'
      page.all('.study-time')[0].click_on 'ー'
      expect(page).not_to have_selector('.modal-thread-list-item')
    end

    it '開始時間、終了時間を入力し作成ボタンを押すと学習時間がカレンダー上に表示されること' do
      visit root_path
      click_on '学習を記録する'
      visit '/?calendar=2022-12'
      expect(page.all('.study-time')[0]).to have_content 'ー'
      page.all('.study-time')[0].click_on 'ー'
      click_on '新規作成'
      expect(page).to have_selector '#startAt'
      fill_in 'startAt', with: '20'
      find('#startAt').send_keys :tab
      fill_in 'startAt', with: '00'
      expect(page).to have_selector '#endAt'
      fill_in 'endAt', with: '20'
      find('#endAt').send_keys :tab
      fill_in 'endAt', with: '30'
      expect(page).to have_field 'endAt', with: '20:30'
      expect(page).not_to have_content('開始時間を入力してください')
      expect(page).not_to have_content('終了時間を入力してください')
      expect(find('#createNewStudyRecordButton')).not_to be_disabled
      click_on '作成'
      expect(page.all('.study-time')[0]).to have_content '30分'
    end

    it '終了時間が開始時間より小さい場合、終了時間は翌日扱いとして登録されること' do
      visit root_path
      click_on '学習を記録する'
      visit '/?calendar=2022-12'
      expect(page.all('.study-time')[0]).to have_content 'ー'
      page.all('.study-time')[0].click_on 'ー'
      click_on '新規作成'
      expect(page).to have_selector '#startAt'
      fill_in 'startAt', with: '20'
      find('#startAt').send_keys :tab
      fill_in 'startAt', with: '00'
      expect(page).to have_selector '#endAt'
      fill_in 'endAt', with: '19'
      find('#endAt').send_keys :tab
      fill_in 'endAt', with: '00'
      expect(page).to have_field 'endAt', with: '19:00'
      expect(page).not_to have_content('開始時間を入力してください')
      expect(page).not_to have_content('終了時間を入力してください')
      expect(find('#createNewStudyRecordButton')).not_to be_disabled
      click_on '作成'
      expect(page.all('.study-time')[0]).to have_content '1380分'
    end

    it '開始時間が不完全な場合、validateメッセージが表示され作成ボタンが押せないこと' do
      visit root_path
      click_on '学習を記録する'
      visit '/?calendar=2022-12'
      expect(page.all('.study-time')[0]).to have_content 'ー'
      page.all('.study-time')[0].click_on 'ー'
      click_on '新規作成'
      fill_in 'startAt', with: '20'
      expect(page).to have_content '開始時間を入力してください'
      expect(find('#createNewStudyRecordButton')).to be_disabled
    end

    it '終了時間が不完全な場合、validateメッセージが表示され作成ボタンが押せないこと' do
      visit root_path
      click_on '学習を記録する'
      visit '/?calendar=2022-12'
      expect(page.all('.study-time')[0]).to have_content 'ー'
      page.all('.study-time')[0].click_on 'ー'
      click_on '新規作成'
      fill_in 'endAt', with: '20'
      expect(page).to have_content '終了時間を入力してください'
      expect(find('#createNewStudyRecordButton')).to be_disabled
    end

    it '既存の学習記録を編集できること' do
      visit root_path
      click_on '学習を記録する'
      visit '/?calendar=2022-12'
      click_on '60分'
      find('button[data-method="edit"]').click
      expect(page).to have_selector '#startAt'
      fill_in 'startAt', with: '21'
      find('#startAt').send_keys :tab
      fill_in 'startAt', with: '00'
      expect(page).to have_field 'startAt', with: '21:00'
      fill_in 'memoContent', with: '編集のテスト'
      click_button '保存'
      within all('.modal-thread-list-item')[0] do
        expect(page.all('.modal-thread-list-contents')[0]).to have_content '21:00'
        expect(page.all('.modal-thread-list-contents')[2]).to have_content '26分'
        expect(page.all('.modal-thread-list-contents')[3]).to have_content '編集のテスト'
      end
    end
  end
end
