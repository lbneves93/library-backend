require 'rails_helper'

RSpec.describe Ability, type: :model do
  let(:member_user) { create(:user, role: 'member') }
  let(:librarian_user) { create(:user, role: 'librarian') }
  let(:book) { create(:book) }
  let(:borrow) { create(:borrow, borrower: member_user) }

  describe 'member user abilities' do
    subject { described_class.new(member_user) }

    it 'can read books' do
      expect(subject.can?(:read, Book)).to be true
    end

    it 'can read dashboard' do
      expect(subject.can?(:read, :dashboard)).to be true
    end

    it 'can borrow books' do
      expect(subject.can?(:borrow, Book)).to be true
    end

    it 'cannot create books' do
      expect(subject.can?(:create, Book)).to be false
    end

    it 'cannot update books' do
      expect(subject.can?(:update, Book)).to be false
    end

    it 'cannot destroy books' do
      expect(subject.can?(:destroy, Book)).to be false
    end

    it 'cannot update borrows' do
      expect(subject.can?(:update, Borrow)).to be false
    end

    it 'can read own borrows' do
      expect(subject.can?(:read, borrow)).to be true
    end

    it 'cannot read other users borrows' do
      other_borrow = create(:borrow, borrower: librarian_user)
      expect(subject.can?(:read, other_borrow)).to be false
    end
  end

  describe 'librarian user abilities' do
    subject { described_class.new(librarian_user) }

    it 'can read books' do
      expect(subject.can?(:read, Book)).to be true
    end

    it 'can read dashboard' do
      expect(subject.can?(:read, :dashboard)).to be true
    end

    it 'can borrow books' do
      expect(subject.can?(:borrow, Book)).to be true
    end

    it 'can create books' do
      expect(subject.can?(:create, Book)).to be true
    end

    it 'can update books' do
      expect(subject.can?(:update, Book)).to be true
    end

    it 'can destroy books' do
      expect(subject.can?(:destroy, Book)).to be true
    end

    it 'can update borrows' do
      expect(subject.can?(:update, Borrow)).to be true
    end

    it 'can update any borrow' do
      expect(subject.can?(:update, borrow)).to be true
    end
  end

  describe 'unauthenticated user' do
    subject { described_class.new(nil) }

    it 'has no abilities' do
      expect(subject.can?(:read, Book)).to be false
      expect(subject.can?(:create, Book)).to be false
      expect(subject.can?(:update, Book)).to be false
      expect(subject.can?(:destroy, Book)).to be false
      expect(subject.can?(:borrow, Book)).to be false
      expect(subject.can?(:read, :dashboard)).to be false
    end
  end
end
