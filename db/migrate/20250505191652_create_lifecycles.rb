class CreateLifecycles < ActiveRecord::Migration[6.1]
  def change
    create_table :lifecycles, id: :integer do |t|
      t.integer :issue_id, null: false
      t.integer :journal_id
      t.integer :user_id, null: false
      t.integer :status_id, null: false
      t.datetime :start, null: false
      t.datetime :end
      t.integer :duration
    end
  end
end
