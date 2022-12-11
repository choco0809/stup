# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Userモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    let(:user) { FactoryBot.build(:user) }
    context 'uidに値が入っている時' do
      it 'uidが存在する場合、バリエーションをパスする' do
        expect(user).to be_valid
      end
    end

    context 'uidがnilの時' do
      it 'uidが空の場合、バリデーションに失敗する' do
        user.uid = nil
        expect(user).to_not be_valid
      end
    end
  end

  describe 'find_or_create_from_auth_hash' do
    before do
      @uid = '1234567'
      @image = 'sample.jpg'
    end
    let(:auth_hash) do
      {
        uid: @uid,
        info: { image: @image }
      }
    end
    context 'uidに対応するUserが存在しない場合' do
      it '引数のuid、imageがUserモデルに登録されている' do
        user = User.find_or_create_from_auth_hash(auth_hash)
        expect(user).to eq User.find_by(uid: @uid)
      end
      it 'Userモデルのレコード件数が増えていること' do
        expect { User.find_or_create_from_auth_hash(auth_hash) }.to change { User.count }.from(0).to(1)
      end
    end

    context 'uidに対応するUserが存在する場合' do
      let!(:created_user) { FactoryBot.create(:user, uid: @uid, image: @image) }
      it '引数と一致するUserレコードのオブジェクトが返されること' do
        user = User.find_or_create_from_auth_hash(auth_hash)
        expect(user).to eq created_user
      end

      it 'Userモデルのレコード件数が変化しないこと' do
        expect { User.find_or_create_from_auth_hash(auth_hash) }.not_to change(User, :count)
      end
    end
  end
end
