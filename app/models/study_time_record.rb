# frozen_string_literal: true

class StudyTimeRecord < ApplicationRecord
  belongs_to :user, foreign_key: :user_id
  validates :memo, length: { maximum: 20 }

  scope :monthly_study_records, lambda { |year, month|
    where("to_char(started_at,'yyyy') = ?", year)
    where("to_char(started_at,'mm') = ?", month)
  }

  def self.check_ready_started?
    !all.empty? && all.last.ended_at.nil?
  end

  def self.check_ready_ended?
    all.empty? || !all.last.ended_at.nil?
  end
end
