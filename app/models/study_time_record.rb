# frozen_string_literal: true

class StudyTimeRecord < ApplicationRecord
  belongs_to :user, foreign_key: :user_id

  class << self
    def annual_study_records(user, year)
      StudyTimeRecord
        .where(user_id: user.id)
        .where("to_char(started_at,'yyyy') = ?", year)
    end

    def monthly_study_records(user, year, month)
      StudyTimeRecord
        .where(user_id: user.id)
        .where("to_char(started_at,'yyyy') = ?", year)
        .where("to_char(started_at,'mm') = ?", month)
    end
  end
end
