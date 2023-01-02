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

    it 'モーダルウィンドウが表示されていること' do
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

    it '学習記録を削除できること' do
      visit root_path
      click_on '学習を記録する'
      visit '/?calendar=2022-12'
      expect(page.all('.study-time')[15]).to have_content '60分'
      click_on '60分'
      within all('.modal-thread-list-item')[0] do
        expect(page.all('.modal-thread-list-contents')[0]).to have_content '20:26'
        expect(page.all('.modal-thread-list-contents')[1]).to have_content '21:26'
        expect(page.all('.modal-thread-list-contents')[2]).to have_content '60分'
        click_on '削除'
      end
      expect(page.all('.study-time')[15]).to have_content 'ー'
    end

    it '学習記録がないとき、レコードが表示されないこと' do
      visit root_path
      click_on '学習を記録する'
      visit '/?calendar=2022-12'
      expect(page.all('.study-time')[0]).to have_content 'ー'
      page.all('.study-time')[0].click_on 'ー'
      expect(page).not_to have_selector('.modal-thread-list-item')
    end

    it '学習記録を作成できること' do
      visit root_path
      click_on '学習を記録する'
      visit '/?calendar=2022-12'
      expect(page.all('.study-time')[0]).to have_content 'ー'
      page.all('.study-time')[0].click_on 'ー'
      click_on '新規作成'
      find('#startedHours').find("option[value='0']").select_option
      find('#startedMinutes').find("option[value='0']").select_option
      find('#endedHours').find("option[value='0']").select_option
      find('#endedMinutes').find("option[value='30']").select_option
      click_on '作成'
      expect(page.all('.study-time')[0]).to have_content '30分'
    end

    it '学習記録を編集できること'

  end

end
