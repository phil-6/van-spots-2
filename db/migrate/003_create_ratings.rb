class CreateRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :ratings do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :spot, null: false, foreign_key: true
      t.integer :score
      t.string :review_title
      t.text :review_body

      t.timestamps
    end
  end
end
