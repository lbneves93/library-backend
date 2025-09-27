p 'Creating users...'

users = [
  { name: 'Librarian', email: 'librarian@email.com', password: 'librarian123', role: 1, jti: 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6' },
  { name: 'First Member', email: 'member@email.com', password: 'member123', role: 0, jti: 'f1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p7' },
  { name: 'Second Member', email: 'member2@email.com', password: 'member123', role: 0, jti: 'b1b2c3d4e5f6g7h8i9j0k1l2m3n4o5d7' }
]

users.each { |user| User.create(user) }