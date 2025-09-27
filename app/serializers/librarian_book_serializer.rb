class LibrarianBookSerializer < ActiveModel::Serializer
  attributes :id, :title, :author, :genre, :isbn, :total_copies, :available, :created_at, :updated_at, :borrows

  def borrows
    object.borrows.map do |borrow|
      {
        id: borrow.id,
        borrower_id: borrow.borrower_id,
        borrower_name: borrow.borrower.name,
        borrower_email: borrow.borrower.email,
        borrowed_at: borrow.borrowed_at,
        due_at: borrow.due_at,
        returned: borrow.returned,
        created_at: borrow.created_at,
        updated_at: borrow.updated_at
      }
    end
  end
end
