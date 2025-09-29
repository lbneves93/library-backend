p 'Creating books...'

books = [
  { title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Fiction', isbn: '9780743273565', total_copies: 5 },
  { title: 'To Kill a Mockingbird', author: 'Harper Lee', genre: 'Fiction', isbn: '9780061120084', total_copies: 3 },
  { title: '1984', author: 'George Orwell', genre: 'Dystopian Fiction', isbn: '9780451524935', total_copies: 2 },
  { title: 'Pride and Prejudice', author: 'Jane Austen', genre: 'Romance', isbn: '9780141439518', total_copies: 6 },
  { title: 'The Catcher in the Rye', author: 'J.D. Salinger', genre: 'Fiction', isbn: '9780316769174', total_copies: 2 },
  { title: 'Lord of the Flies', author: 'William Golding', genre: 'Fiction', isbn: '9780571056866', total_copies: 3 },
  { title: 'The Hobbit', author: 'J.R.R. Tolkien', genre: 'Fantasy', isbn: '9780547928227', total_copies: 7 },
  { title: 'Harry Potter and the Sorcerer\'s Stone', author: 'J.K. Rowling', genre: 'Fantasy', isbn: '9780590353427', total_copies: 8 },
  { title: 'The Chronicles of Narnia', author: 'C.S. Lewis', genre: 'Fantasy', isbn: '9780064471190', total_copies: 5 },
  { title: 'The Alchemist', author: 'Paulo Coelho', genre: 'Fiction', isbn: '9780061122415', total_copies: 4 },
  { title: 'The Da Vinci Code', author: 'Dan Brown', genre: 'Mystery', isbn: '9780307474278', total_copies: 6 },
  { title: 'The Kite Runner', author: 'Khaled Hosseini', genre: 'Fiction', isbn: '9781594631931', total_copies: 3 },
  { title: 'The Book Thief', author: 'Markus Zusak', genre: 'Historical Fiction', isbn: '9780375831003', total_copies: 4 },
  { title: 'The Hunger Games', author: 'Suzanne Collins', genre: 'Dystopian Fiction', isbn: '9780439023481', total_copies: 5 },
  { title: 'The Fault in Our Stars', author: 'John Green', genre: 'Young Adult', isbn: '9780525478812', total_copies: 3 },
  { title: 'Gone Girl', author: 'Gillian Flynn', genre: 'Thriller', isbn: '9780307588364', total_copies: 4 },
  { title: 'The Girl with the Dragon Tattoo', author: 'Stieg Larsson', genre: 'Mystery', isbn: '9780307269751', total_copies: 3 },
  { title: 'The Help', author: 'Kathryn Stockett', genre: 'Historical Fiction', isbn: '9780399155345', total_copies: 4 },
  { title: 'The Road', author: 'Cormac McCarthy', genre: 'Post-Apocalyptic', isbn: '9780307387899', total_copies: 2 },
  { title: 'Life of Pi', author: 'Yann Martel', genre: 'Adventure Fiction', isbn: '9780156027328', total_copies: 3 }
]

books.each { |book| Book.create(book) }
