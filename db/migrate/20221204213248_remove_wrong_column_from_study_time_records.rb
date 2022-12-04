class RemoveWrongColumnFromStudyTimeRecords < ActiveRecord::Migration[7.0]
  def up
    remove_column :study_time_records, :'{:null=>false}'
  end

  def down
    add_column :study_time_records, :'{:null=>false}', :datetime
  end

end
