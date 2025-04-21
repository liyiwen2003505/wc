class AddAvatarToAuthors < ActiveRecord::Migration[8.0]
  def change
    add_column :authors, :avatar, :string
    add_column :authors, :avatar_size, :integer
  end
end
