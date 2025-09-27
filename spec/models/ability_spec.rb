require 'rails_helper'

RSpec.describe Ability, type: :model do
  let(:member_user) { create(:user, role: 'member') }
  let(:librarian_user) { create(:user, role: 'librarian') }
  let(:book) { create(:book) }
  let(:borrow) { create(:borrow, borrower: member_user) }

  describe 'member user abilities' do
    subject { described_class.new(member_user) }

    it 'can read books' do
      expect(subject).to be_able_to(:read, Book)
    end

    it 'can read dashboard' do
      expect(subject).to be_able_to(:read, :dashboard)
    end

    it 'can borrow books' do
      expect(subject).to be_able_to(:borrow, Book)
    end

    it 'cannot create books' do
      expect(subject).not_to be_able_to(:create, Book)
    end

    it 'cannot update books' do
      expect(subject).not_to be_able_to(:update, Book)
    end

    it 'cannot destroy books' do
      expect(subject).not_to be_able_to(:destroy, Book)
    end

    it 'cannot update borrows' do
      expect(subject).not_to be_able_to(:update, Borrow)
    end

    it 'can read own borrows' do
      expect(subject).to be_able_to(:read, borrow)
    end

    it 'cannot read other users borrows' do
      other_borrow = create(:borrow, borrower: librarian_user)
      expect(subject).not_to be_able_to(:read, other_borrow)
    end
  end

  describe 'librarian user abilities' do
    subject { described_class.new(librarian_user) }

    it 'can read books' do
      expect(subject).to be_able_to(:read, Book)
    end

    it 'can read dashboard' do
      expect(subject).to be_able_to(:read, :dashboard)
    end

    it 'can borrow books' do
      expect(subject).to be_able_to(:borrow, Book)
    end

    it 'can create books' do
      expect(subject).to be_able_to(:create, Book)
    end

    it 'can update books' do
      expect(subject).to be_able_to(:update, Book)
    end

    it 'can destroy books' do
      expect(subject).to be_able_to(:destroy, Book)
    end

    it 'can update borrows' do
      expect(subject).to be_able_to(:update, Borrow)
    end

    it 'can read any borrow' do
      expect(subject).to be_able_to(:read, borrow)
    end
  end

  describe 'unauthenticated user' do
    subject { described_class.new(nil) }

    it 'has no abilities' do
      expect(subject).not_to be_able_to(:read, Book)
      expect(subject).not_to be_able_to(:create, Book)
      expect(subject).not_to be_able_to(:update, Book)
      expect(subject).not_to be_able_to(:destroy, Book)
      expect(subject).not_to be_able_to(:borrow, Book)
      expect(subject).not_to be_able_to(:read, :dashboard)
    end
  end
end
