# frozen_string_literal: true

module Api
  module Discord
    class StudyTimeRecordsController < ActionController::API
      before_action :set_user

      STUP_URL = 'https://stup.fly.dev/'
      UNREGISTERED_USER = "ユーザーが登録されていません。\n下記のURLからユーザー登録を行った後、再度実行して下さい🙇\n#{STUP_URL}".freeze
      START_REPORT = '学習の記録を開始しました🙆'
      FINISH_REPORT = '学習が終了しました🙆'
      INCOMPLETE_REPORT = '前回の学習記録が終了していません🙅'
      NOT_STARTED = "学習が開始されていません。\n学習の記録を開始してください🙇"
      OVER_24_HOURS = "前回の学習記録から24時間以上経過しています。\n下記のURLから手動にて終了時間を記入して下さい🙇\n#{STUP_URL}".freeze

      def create
        return render status: :ok, json: { message: UNREGISTERED_USER } if @user.nil?

        @study_time_records = @user.study_time_records
        if @study_time_records.check_ready_started?
          return render status: :ok, json: { message: reply_incomplete_report(@study_time_records.last) }
        end

        new_record = @study_time_records.new(started_at: params[:started_at], memo: params[:memo])
        new_record.save!
        render status: :ok, json: { message: START_REPORT }
      end

      def update
        return render status: :ok, json: { message: UNREGISTERED_USER } if @user.nil?

        @study_time_records = @user.study_time_records
        return render status: :ok, json: { message: NOT_STARTED } if @study_time_records.check_ready_ended?

        if @study_time_records.last.within_24_hours?(params[:ended_at])
          return render status: :ok, json: { message: OVER_24_HOURS }
        end

        @study_time_records.last.update!(ended_at: params[:ended_at])
        render status: :ok, json: { message: FINISH_REPORT }
      end

      private

      def reply_incomplete_report(latest_record)
        "#{INCOMPLETE_REPORT}\n#{format_time_zone(latest_record.started_at)}"
      end

      def format_time_zone(time)
        time.strftime('%Y/%m/%d %H:%M')
      end

      def set_user
        @user = User.find_by(uid: params[:uid])
      end
    end
  end
end
