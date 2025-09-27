require 'rails_helper'

RSpec.describe Book, type: :model do
  describe 'validations' do
    let(:book) { build(:book) }

    it 'is valid with valid attributes' do
      expect(book).to be_valid
    end

    describe 'title' do
      it 'is required' do
        book.title = nil
        expect(book).not_to be_valid
        expect(book.errors[:title]).to include("can't be blank")
      end

      it 'must be at least 1 character long' do
        book.title = ''
        expect(book).not_to be_valid
        expect(book.errors[:title]).to include('is too short (minimum is 1 character)')
      end

      it 'must be at most 255 characters long' do
        book.title = 'a' * 256
        expect(book).not_to be_valid
        expect(book.errors[:title]).to include('is too long (maximum is 255 characters)')
      end
    end

    describe 'author' do
      it 'is required' do
        book.author = nil
        expect(book).not_to be_valid
        expect(book.errors[:author]).to include("can't be blank")
      end

      it 'must be at least 1 character long' do
        book.author = ''
        expect(book).not_to be_valid
        expect(book.errors[:author]).to include('is too short (minimum is 1 character)')
      end

      it 'must be at most 255 characters long' do
        book.author = 'a' * 256
        expect(book).not_to be_valid
        expect(book.errors[:author]).to include('is too long (maximum is 255 characters)')
      end
    end

    describe 'genre' do
      it 'is required' do
        book.genre = nil
        expect(book).not_to be_valid
        expect(book.errors[:genre]).to include("can't be blank")
      end

      it 'must be at least 1 character long' do
        book.genre = ''
        expect(book).not_to be_valid
        expect(book.errors[:genre]).to include('is too short (minimum is 1 character)')
      end

      it 'must be at most 100 characters long' do
        book.genre = 'a' * 101
        expect(book).not_to be_valid
        expect(book.errors[:genre]).to include('is too long (maximum is 100 characters)')
      end
    end

    describe 'isbn' do
      it 'is required' do
        book.isbn = nil
        expect(book).not_to be_valid
        expect(book.errors[:isbn]).to include("can't be blank")
      end

      it 'must be exactly 13 characters long' do
        book.isbn = '123456789012'
        expect(book).not_to be_valid
        expect(book.errors[:isbn]).to include('is the wrong length (should be 13 characters)')
      end

      it 'must be unique' do
        create(:book, isbn: '1234567890123')
        book.isbn = '1234567890123'
        expect(book).not_to be_valid
        expect(book.errors[:isbn]).to include('has already been taken')
      end
    end

    describe 'total_copies' do
      it 'is required' do
        book.total_copies = nil
        expect(book).not_to be_valid
        expect(book.errors[:total_copies]).to include("can't be blank")
      end

      it 'must be a non-negative integer' do
        book.total_copies = -1
        expect(book).not_to be_valid
        expect(book.errors[:total_copies]).to include('must be greater than or equal to 0')
      end

      it 'must be an integer' do
        book.total_copies = 1.5
        expect(book).not_to be_valid
        expect(book.errors[:total_copies]).to include('must be an integer')
      end
    end
  end

  describe 'associations' do
    it { should have_many(:borrows) }
    it { should have_many(:users).through(:borrows) }
  end
end
