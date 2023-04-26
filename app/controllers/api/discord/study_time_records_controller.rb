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

      def create
        return render status: :ok, json: { message: UNREGISTERED_USER } if @user.nil?

        study_time_records = @user.study_time_records
        if check_ready_started?(study_time_records)
          return render status: :ok, json: { message: reply_incomplete_report(study_time_records) }
        end

        study_time_record = study_time_records.new(started_at: params[:started_at], memo: params[:memo])
        study_time_record.save!
        render status: :ok, json: { message: START_REPORT }
      end

      def update
        return render status: :ok, json: { message: UNREGISTERED_USER } if @user.nil?

        study_time_record = StudyTimeRecord.where(user_id: @user.id).last
        return render status: :ok, json: { message: NOT_STARTED } if check_ready_ended?(study_time_record)

        study_time_record.update!(ended_at: params[:ended_at])
        render status: :ok, json: { message: FINISH_REPORT }
      end

      private

      def check_ready_started?(study_time_records)
        records = study_time_records.all
        !records.empty? && records.last.ended_at.nil?
      end

      def check_ready_ended?(records)
        records.nil? || !records.ended_at.nil?
      end

      def reply_incomplete_report(records)
        last_record = records.all.last.started_at
        "#{INCOMPLETE_REPORT}\n#{format_time_zone(last_record)}"
      end

      def format_time_zone(time)
        time.strftime('%Y/%M/%d %H:%M')
      end

      def set_user
        @user = User.find_by(uid: params[:uid])
      end
    end
  end
end
