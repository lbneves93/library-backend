class Book < ApplicationRecord
  validates :title, presence: true, length: { minimum: 1, maximum: 255 }
  validates :author, presence: true, length: { minimum: 1, maximum: 255 }
  validates :genre, presence: true, length: { minimum: 1, maximum: 100 }
  validates :isbn, presence: true, uniqueness: true, length: { is: 13 }
  validates :total_copies, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :available, inclusion: { in: [true, false] }

  # Borrow relationships
  has_many :borrows
  has_many :users, through: :borrows
end
