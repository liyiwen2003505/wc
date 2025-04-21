class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title
      t.references :author, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.integer :total
      t.text :description

      t.timestamps
    end
  end
end
