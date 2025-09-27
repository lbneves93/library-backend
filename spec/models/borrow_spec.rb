require 'rails_helper'

RSpec.describe Borrow, type: :model do
  describe 'associations' do
    it { should belong_to(:borrower).class_name('User') }
    it { should belong_to(:book) }
  end

  describe 'validations' do
    let(:borrow) { build(:borrow) }

    it 'is valid with valid attributes' do
      expect(borrow).to be_valid
    end

    it 'validates presence of borrowed_at' do
      borrow.borrowed_at = nil
      expect(borrow).not_to be_valid
      expect(borrow.errors[:borrowed_at]).to include("can't be blank")
    end

    it 'validates presence of due_at' do
      borrow.due_at = nil
      expect(borrow).not_to be_valid
      expect(borrow.errors[:due_at]).to include("can't be blank")
    end

    it 'validates inclusion of returned' do
      borrow.returned = nil
      expect(borrow).not_to be_valid
      expect(borrow.errors[:returned]).to include('is not included in the list')
    end
  end

  describe 'custom validations' do
    let(:user) { create(:user) }
    let(:book) { create(:book, available: true, total_copies: 2) }

    context 'book_must_be_available' do
      it 'allows borrowing when book is available' do
        borrow = build(:borrow, borrower: user, book: book)
        expect(borrow).to be_valid
      end

      it 'prevents borrowing when book is not available' do
        book.update!(available: false)
        borrow = build(:borrow, borrower: user, book: book)
        expect(borrow).not_to be_valid
        expect(borrow.errors[:book]).to include('is not available for borrowing')
      end
    end

    context 'user_cannot_borrow_same_book_twice' do
      it 'allows borrowing when user has no active borrows for the book' do
        borrow = build(:borrow, borrower: user, book: book)
        expect(borrow).to be_valid
      end

      it 'prevents borrowing when user already has an active borrow for the book' do
        create(:borrow, borrower: user, book: book, returned: false)
        borrow = build(:borrow, borrower: user, book: book)
        expect(borrow).not_to be_valid
        expect(borrow.errors[:book]).to include('is already borrowed by this user')
      end

      it 'allows borrowing when user has returned the book previously' do
        create(:borrow, borrower: user, book: book, returned: true)
        borrow = build(:borrow, borrower: user, book: book)
        expect(borrow).to be_valid
      end
    end
  end

  describe 'callbacks' do
    let(:user) { create(:user) }
    let(:book) { create(:book, available: true, total_copies: 1) }

    describe 'after_create' do
      it 'updates book availability when all copies are borrowed' do
        expect(book.available).to be true
        create(:borrow, borrower: user, book: book)
        book.reload
        expect(book.available).to be false
      end

      it 'keeps book available when copies are still available' do
        book.update!(total_copies: 2)
        expect(book.available).to be true
        create(:borrow, borrower: user, book: book)
        book.reload
        expect(book.available).to be true
      end
    end

    describe 'after_update' do
      let!(:borrow) { create(:borrow, borrower: user, book: book, returned: false) }

      it 'updates book availability when book is returned' do
        book.reload
        expect(book.available).to be false
        
        borrow.update!(returned: true)
        book.reload
        expect(book.available).to be true
      end

      it 'does not trigger callback when other fields are updated' do
        book.reload
        expect(book.available).to be false
        
        borrow.update!(due_at: 1.week.from_now)
        book.reload
        expect(book.available).to be false
      end
    end
  end
end
