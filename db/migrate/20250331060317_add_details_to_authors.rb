class AddDetailsToAuthors < ActiveRecord::Migration[8.0]
  def change
    add_column :authors, :id_number, :string

    # 添加唯一索引
    add_index :authors, :id_number, unique: true
  end
end
