# frozen_string_literal: true

require 'rails_helper'
require 'capybara/rspec'

RSpec.describe 'Welcome', type: :system do
  let(:user) { FactoryBot.build(:user) }

  before do
    OmniAuth.config.mock_auth[:discord] = nil
    Rails.application.env_config['omniauth.auth'] = discord_oauth(user[:uid], user[:image])
  end

  it 'ユーザーがログインできること' do
    visit root_path
    click_on '学習を記録する'
    expect(page).to have_content 'すたっぷ'
    expect(page).to have_selector("img[src$='#{user[:image]}']")
  end

  it 'ユーザーがログアウトできること' do
    visit root_path
    click_on '学習を記録する'
    expect(page).to have_content 'すたっぷ'
    expect(page).to have_selector("img[src$='#{user[:image]}']")
    find('.avatar_icon').click
    click_on 'ログアウト'
    expect(page).to have_content 'すたっぷ'
    expect(page).to_not have_selector("img[src$='#{user[:image]}']")
  end
end
