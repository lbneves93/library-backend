class Borrow < ApplicationRecord
  belongs_to :borrower, class_name: 'User'
  belongs_to :book

  validates :borrowed_at, presence: true
  validates :due_at, presence: true
  validates :returned, inclusion: { in: [true, false] }
  
  validate :book_must_be_available, on: :create
  validate :user_cannot_borrow_same_book_twice, on: :create

  after_create :update_book_availability_after_borrow
  after_update :update_book_availability_after_return, if: :saved_change_to_returned?

  private

  def book_must_be_available
    return if book.nil?
    
    unless book.available?
      errors.add(:book, 'is not available for borrowing')
    end
  end

  def user_cannot_borrow_same_book_twice
    return if borrower.nil? || book.nil?
    
    existing_borrow = Borrow.where(borrower: borrower, book: book, returned: false)
    if existing_borrow.exists?
      errors.add(:book, 'is already borrowed by this user')
    end
  end

  def update_book_availability_after_borrow
    # Count active borrows for this book
    active_borrows_count = Borrow.where(book: book, returned: false).count
    
    # If all copies are borrowed, mark book as unavailable
    if active_borrows_count >= book.total_copies
      book.update!(available: false)
    end
  end

  def update_book_availability_after_return
    # If book is being returned, make it available again
    if returned?
      book.update!(available: true)
    end
  end
end
