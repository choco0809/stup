# frozen_string_literal: true

class StudyTimeRecord < ApplicationRecord
  belongs_to :user

  def self.not_ended_at?(user)
    records = where(user_id: user.id)
    !records.empty? && records.last.ended_at.nil?
  end
end
