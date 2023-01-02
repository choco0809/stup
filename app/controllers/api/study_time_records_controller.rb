# frozen_string_literal: true

module Api
  class StudyTimeRecordsController < ActionController::API
    include SessionsHelper

    def create
      @user = User.find(current_user.id)
      @study_time_record = @user.study_time_records.new(started_at: params[:started_at], ended_at: params[:ended_at])
      @study_time_record.save!
      @study_time_record
    end

    def destroy
      @user = User.find(current_user.id)
      @study_time_record = @user.study_time_records.find(params[:id])
      @study_time_record.destroy
      @study_time_record
    end

    def show
      year = params[:year]
      month = format('%02d', params[:month])
      @study_time_records = if month.nil?
                              StudyTimeRecord.annual_study_records(current_user, year)
                            else
                              StudyTimeRecord.monthly_study_records(current_user, year, month)
                            end
    end
  end
end
