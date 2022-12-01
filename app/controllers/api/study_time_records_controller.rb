# frozen_string_literal: true

module Api
  class StudyTimeRecordsController < ActionController::API
    def create
      user = User.find_by(uid: params[:uid])
      return render status: :ok, json: { message: 'unregistered' } if user.nil?

      records = StudyTimeRecord.where(user_id: user.id)
      return render status: :ok, json: { message: 'not ended' } if records.not_ended_at?(user)

      study_time_record = records.new(started_at: Time.current)
      if study_time_record.save
        render status: :ok, json: { message: 'registration succeeded' }
      else
        render status: :ok, json: { message: 'registration failed' }
      end
    end
  end
end
