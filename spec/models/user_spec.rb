# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Userモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    it 'uidが存在する場合、バリエーションをパスする' do
      user = FactoryBot.build(:user)
      pp user
      expect(user).to be_valid
    end

    it 'uidが空の場合、バリデーションに失敗する' do
      user = FactoryBot.build(:user, uid: nil)
      pp user
      expect(user).to_not be_valid
    end
  end
end
