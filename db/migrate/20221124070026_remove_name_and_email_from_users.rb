class RemoveNameAndEmailFromUsers < ActiveRecord::Migration[7.0]
  def up
    remove_column :users, :name, :string
    remove_column :users, :email, :string
  end
end
