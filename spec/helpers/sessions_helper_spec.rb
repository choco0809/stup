# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  describe 'current_user' do
    context 'session[:user_id]が存在しない時' do
      it 'nilで返ってくること' do
        session[:user_id] = nil
        expect(current_user).to eq nil
      end
    end

    context 'session[:user_id]が存在する時' do
      let!(:user) { FactoryBot.create(:user) }
      it 'session[:user_id]と同じオブジェクトが返ってくること' do
        session[:user_id] = User.find_by(uid: user[:uid])[:id]
        expect(current_user).to eq user
      end
    end
  end

  describe 'log_in' do
    let!(:user) { FactoryBot.create(:user) }
    it 'session[:user_id]とUserのidが等しいこと' do
      log_in(user)
      expect(session[:user_id]).to eq User.find_by(uid: user[:uid])[:id]
    end
  end

  describe 'log_out' do
    it 'session[:user_id]がnilになること' do
      session[:user_id] = '1'
      expect(log_out).to eq nil
      expect(session[:user_id]).to eq nil
    end
  end
end
