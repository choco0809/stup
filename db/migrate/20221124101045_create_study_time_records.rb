class CreateStudyTimeRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :study_time_records do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :started_at, { null: false }
      t.datetime :ended_at
      t.string :memo

      t.timestamps
    end
  end
end
