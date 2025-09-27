p 'Creating borrows...'

# Find the members user
first_member = User.find_by(email: 'member@email.com')
second_member = User.find_by(email: 'member2@email.com')

# Borrows for first member
books = Book.first(5)
borrows = [
  {
    borrower_id: first_member.id,
    book_id: books[0].id,
    borrowed_at: 1.week.ago,
    due_at: 1.week.from_now,
    returned: false
  },
  {
    borrower_id: first_member.id,
    book_id: books[1].id,
    borrowed_at: 17.days.ago,
    due_at: 3.days.ago,
    returned: true
  },
  {
    borrower_id: first_member.id,
    book_id: books[2].id,
    borrowed_at: 2.days.ago,
    due_at: 12.days.from_now,
    returned: false
  },
  {
    borrower_id: second_member.id,
    book_id: books[3].id,
    borrowed_at: 2.days.ago,
    due_at: 12.days.from_now,
    returned: false
  },
  {
    borrower_id: second_member.id,
    book_id: books[4].id,
    borrowed_at: 4.days.ago,
    due_at: 12.days.from_now,
    returned: true
  },
  {
    borrower_id: second_member.id,
    book_id: books[2].id,
    borrowed_at: 15.days.ago,
    due_at: 2.days.ago,
    returned: false
  }
]

borrows.each { |borrow| Borrow.create(borrow) }
