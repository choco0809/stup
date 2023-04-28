# frozen_string_literal: true

module Api
  class StudyTimeRecordsController < ActionController::API
    include SessionsHelper
    include ActionController::RequestForgeryProtection
    protect_from_forgery with: :exception
    before_action :set_user, only: %i[create destroy update show]
    before_action :set_study_time_record, only: %i[destroy update]

    def create
      @study_time_record = @user.study_time_records.new(study_time_record_params)
      @study_time_record.save!
      @study_time_record
    end

    def destroy
      @study_time_record.destroy
      @study_time_record
    end

    def show
      year = params[:year]
      month = format('%02d', params[:month])
      @study_time_records = @user.study_time_records.monthly_study_records(year, month)
    end

    def update
      @study_time_record.assign_attributes(study_time_record_params)
      @study_time_record.save!
      @study_time_record
    end

    private

    def set_user
      @user = User.find(current_user.id)
    end

    def set_study_time_record
      @study_time_record = @user.study_time_records.find(params[:id])
    end

    def study_time_record_params
      params.require(:study_time_record).permit(:started_at, :ended_at, :memo)
    end
  end
end
