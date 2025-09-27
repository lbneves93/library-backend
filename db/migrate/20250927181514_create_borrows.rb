class CreateBorrows < ActiveRecord::Migration[8.0]
  def change
    create_table :borrows do |t|
      t.references :borrower, null: false, foreign_key: { to_table: :users }
      t.references :book, null: false, foreign_key: true
      t.datetime :borrowed_at, null: false
      t.datetime :due_at, null: false
      t.boolean :returned, default: false, null: false

      t.timestamps
    end
  end
end
