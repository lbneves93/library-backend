# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    # All authenticated users can read books and use dashboard
    can :read, Book
    can :read, :dashboard
    can :borrow, Book

    # Only librarians can create, update, and destroy books
    if user.librarian?
      can :create, Book
      can :update, Book
      can :destroy, Book
      can :update, Borrow
    end

    # Members can only read their own borrows
    if user.member?
      can :read, Borrow, borrower_id: user.id
    end
  end
end
