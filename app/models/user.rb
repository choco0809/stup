# frozen_string_literal: true

class User < ApplicationRecord
  has_many :study_time_records, foreign_key: :user_id
  validates :uid, presence: true

  class << self
    def find_or_create_from_auth_hash(auth_hash)
      find_or_create_by(uid: auth_hash[:uid], image: auth_hash[:info][:image])
    end
  end
end
