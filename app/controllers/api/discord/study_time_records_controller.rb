# frozen_string_literal: true

module Api
  module Discord
    class StudyTimeRecordsController < ActionController::API
      before_action :set_user

      def create
        return render status: :ok, json: { message: 'ユーザーが未登録です' } if @user.nil?

        records = StudyTimeRecord.where(user_id: @user.id)
        return render status: :ok, json: { message: '前回の学習記録が終了していません' } if check_ready_started?(records)

        study_time_record = records.new(started_at: params[:started_at])
        if study_time_record.save
          render status: :ok, json: { message: '学習の記録を開始しました' }
        else
          render status: :ok, json: { message: 'エラーメッセージ' }
        end
      end

      def update
        return render status: :ok, json: { message: 'ユーザーが未登録です' } if @user.nil?

        records = StudyTimeRecord.where(user_id: @user.id).last

        return render status: :ok, json: { message: '学習が開始されていません' } if check_ready_ended?(records)

        if records.update(ended_at: params[:ended_at])
          render status: :ok, json: { message: '学習が終了しました' }
        else
          render status: :ok, json: { message: 'エラーメッセージ' }
        end
      end

      private

      def check_ready_started?(records)
        !records.empty? && records.last.ended_at.nil?
      end

      def check_ready_ended?(records)
        records.nil? || !records.ended_at.nil?
      end

      def set_user
        @user = User.find_by(uid: params[:uid])
      end
    end
  end
end
