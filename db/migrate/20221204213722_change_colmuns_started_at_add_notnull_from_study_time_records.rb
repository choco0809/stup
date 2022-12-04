class ChangeColmunsStartedAtAddNotnullFromStudyTimeRecords < ActiveRecord::Migration[7.0]
  def change
    change_column_null :study_time_records, :started_at, false
  end
end
