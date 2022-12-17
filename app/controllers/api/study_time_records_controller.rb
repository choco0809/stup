# frozen_string_literal: true

module Api
  class StudyTimeRecordsController < ActionController::API
    include SessionsHelper

    def show
      year = params[:year]
      month = params[:month]
      @study_time_records = if month.nil?
                              StudyTimeRecord.annual_study_records(current_user, year)
                            else
                              StudyTimeRecord.monthly_study_records(current_user, year, month)
                            end
    end
  end
end
