class CreateStages < ActiveRecord::Migration[6.1]
  def change
    create_table :stages do |t|
      t.integer :issue_id, null: false
      t.integer :journal_id
      t.integer :user_id, null: false
      t.integer :status_id, null: false
      t.integer :category_id
      t.datetime :start, null: false
      t.datetime :end
      t.integer :time_spent
    end
    add_index :stages, :issue_id
    add_index :stages, :journal_id
    add_index :stages, :user_id
    add_index :stages, :status_id
    add_index :stages, :category_id

    add_foreign_key :stages, :issues, on_delete: :cascade
  end
end
