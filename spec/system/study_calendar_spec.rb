# frozen_string_literal: true

require 'rails_helper'
require 'capybara/rspec'

RSpec.describe 'StudyCalender', type: :system do
  let!(:user) { FactoryBot.create(:user) }

  before do
    OmniAuth.config.mock_auth[:discord] = nil
    Rails.application.env_config['omniauth.auth'] = discord_oauth(user[:uid], user[:image])
  end

  describe 'カレンダーのテスト' do
    before do
      @current_user = User.find_by(uid: user.uid)
    end

    it 'カレンダーの曜日が表示されていること' do
      visit root_path
      click_on '学習を記録する'
      expect(page).to have_selector 'th', text: '日'
      expect(page).to have_selector 'th', text: '月'
      expect(page).to have_selector 'th', text: '火'
      expect(page).to have_selector 'th', text: '水'
      expect(page).to have_selector 'th', text: '木'
      expect(page).to have_selector 'th', text: '金'
    end

    it '当月のカレンダーに学習時間の合計が表示されていること' do
      StudyTimeRecord.create(
        user_id: @current_user.id,
        started_at: '2022-11-16 20:26:00',
        ended_at: '2022-11-16 21:26:00',
        memo: ''
      )
      visit root_path
      click_on '学習を記録する'
      visit '/?calendar=2022-11'
      expect(page.all('.study-time')[15]).to have_content '60分'
    end
  end
end
