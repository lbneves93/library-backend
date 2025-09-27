require 'rails_helper'

RSpec.describe "Books", type: :request do
  let(:user) { create(:user) }
  let(:book) { create(:book) }
  let(:valid_attributes) { attributes_for(:book) }
  let(:invalid_attributes) { { title: '', author: '', genre: '', isbn: '123', total_copies: -1 } }

  before do
    sign_in user
  end

  describe "GET /books" do
    it "returns http success" do
      get books_path
      expect(response).to have_http_status(:success)
    end

    it "returns all books" do
      create_list(:book, 3)
      get books_path
      expect(JSON.parse(response.body).length).to eq(3)
    end

    describe "search" do
      let!(:book1) { create(:book, title: "The Great Gatsby", author: "F. Scott Fitzgerald", genre: "Fiction") }
      let!(:book2) { create(:book, title: "1984", author: "George Orwell", genre: "Dystopian Fiction") }
      let!(:book3) { create(:book, title: "Pride and Prejudice", author: "Jane Austen", genre: "Romance") }
      let!(:book4) { create(:book, title: "The Hobbit", author: "J.R.R. Tolkien", genre: "Fantasy") }

      context "when searching by title" do
        it "returns books matching the title" do
          get books_path, params: { search: "Gatsby" }
          books = JSON.parse(response.body)
          expect(books.length).to eq(1)
          expect(books.first['title']).to eq("The Great Gatsby")
        end

        it "returns books with partial title match" do
          get books_path, params: { search: "Great" }
          books = JSON.parse(response.body)
          expect(books.length).to eq(1)
          expect(books.first['title']).to eq("The Great Gatsby")
        end

        it "is case insensitive" do
          get books_path, params: { search: "gatsby" }
          books = JSON.parse(response.body)
          expect(books.length).to eq(1)
          expect(books.first['title']).to eq("The Great Gatsby")
        end
      end

      context "when searching by author" do
        it "returns books matching the author" do
          get books_path, params: { search: "Orwell" }
          books = JSON.parse(response.body)
          expect(books.length).to eq(1)
          expect(books.first['author']).to eq("George Orwell")
        end

        it "returns books with partial author match" do
          get books_path, params: { search: "George" }
          books = JSON.parse(response.body)
          expect(books.length).to eq(1)
          expect(books.first['author']).to eq("George Orwell")
        end

        it "is case insensitive" do
          get books_path, params: { search: "orwell" }
          books = JSON.parse(response.body)
          expect(books.length).to eq(1)
          expect(books.first['author']).to eq("George Orwell")
        end
      end

      context "when searching by genre" do
        it "returns books matching the genre" do
          get books_path, params: { search: "Fiction" }
          books = JSON.parse(response.body)
          expect(books.length).to eq(2)
          expect(books.map { |b| b['title'] }).to contain_exactly("The Great Gatsby", "1984")
        end

        it "returns books with partial genre match" do
          get books_path, params: { search: "Fantasy" }
          books = JSON.parse(response.body)
          expect(books.length).to eq(1)
          expect(books.first['title']).to eq("The Hobbit")
        end

        it "is case insensitive" do
          get books_path, params: { search: "fiction" }
          books = JSON.parse(response.body)
          expect(books.length).to eq(2)
        end
      end

      context "when searching across multiple fields" do
        it "returns books matching any field" do
          get books_path, params: { search: "Jane" }
          books = JSON.parse(response.body)
          expect(books.length).to eq(1)
          expect(books.first['author']).to eq("Jane Austen")
        end

        it "returns multiple books when search term matches multiple fields" do
          # Create a book where title contains "The" and another where author contains "The"
          create(:book, title: "The Road", author: "Cormac McCarthy", genre: "Post-Apocalyptic")
          get books_path, params: { search: "The" }
          books = JSON.parse(response.body)
          expect(books.length).to eq(3) # The Great Gatsby, The Hobbit, The Road
        end
      end

      context "when no search results found" do
        it "returns empty array" do
          get books_path, params: { search: "NonExistentBook" }
          books = JSON.parse(response.body)
          expect(books.length).to eq(0)
        end
      end

      context "when search parameter is empty" do
        it "returns all books" do
          get books_path, params: { search: "" }
          books = JSON.parse(response.body)
          expect(books.length).to eq(4)
        end
      end

      context "when search parameter is nil" do
        it "returns all books" do
          get books_path, params: { search: nil }
          books = JSON.parse(response.body)
          expect(books.length).to eq(4)
        end
      end

      context "when no search parameter provided" do
        it "returns all books" do
          get books_path
          books = JSON.parse(response.body)
          expect(books.length).to eq(4)
        end
      end

      context "when searching with special characters" do
        let!(:special_book) { create(:book, title: "The Cat's Cradle", author: "Kurt Vonnegut", genre: "Science Fiction") }

        it "handles apostrophes in search" do
          get books_path, params: { search: "Cat's" }
          books = JSON.parse(response.body)
          expect(books.length).to eq(1)
          expect(books.first['title']).to eq("The Cat's Cradle")
        end

        it "handles apostrophes in partial search" do
          get books_path, params: { search: "Cat" }
          books = JSON.parse(response.body)
          expect(books.length).to eq(1)
          expect(books.first['title']).to eq("The Cat's Cradle")
        end
      end

      context "when searching with whitespace" do
        it "trims whitespace and searches" do
          get books_path, params: { search: "  Gatsby  " }
          books = JSON.parse(response.body)
          expect(books.length).to eq(1)
          expect(books.first['title']).to eq("The Great Gatsby")
        end
      end
    end
  end

  describe "GET /books/:id" do
    it "returns http success" do
      get book_path(book)
      expect(response).to have_http_status(:success)
    end

    it "returns the specific book" do
      get book_path(book)
      expect(JSON.parse(response.body)['id']).to eq(book.id)
    end

    it "returns 404 for non-existent book" do
      get book_path(999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /books" do
    context "with valid parameters" do
      it "creates a new book" do
        expect {
          post books_path, params: { book: valid_attributes }
        }.to change(Book, :count).by(1)
      end

      it "returns http created" do
        post books_path, params: { book: valid_attributes }
        expect(response).to have_http_status(:created)
      end

      it "returns the created book" do
        post books_path, params: { book: valid_attributes }
        expect(JSON.parse(response.body)['title']).to eq(valid_attributes[:title])
      end
    end

    context "with invalid parameters" do  
      it "does not create a new book" do
        expect {
          post books_path, params: { book: invalid_attributes }
        }.not_to change(Book, :count)
      end

      it "returns http unprocessable entity" do
        post books_path, params: { book: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns validation errors" do
        post books_path, params: { book: invalid_attributes }
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe "PATCH /books/:id" do
    context "with valid parameters" do
      let(:new_attributes) { { title: 'Updated Title' } }

      it "updates the book" do
        patch book_path(book), params: { book: new_attributes }
        book.reload
        expect(book.title).to eq('Updated Title')
      end

      it "returns http success" do
        patch book_path(book), params: { book: new_attributes }
        expect(response).to have_http_status(:success)
      end

      it "returns the updated book" do
        patch book_path(book), params: { book: new_attributes }
        expect(JSON.parse(response.body)['title']).to eq('Updated Title')
      end
    end

    context "with invalid parameters" do
      it "does not update the book" do
        original_title = book.title
        patch book_path(book), params: { book: invalid_attributes }
        book.reload
        expect(book.title).to eq(original_title)
      end

      it "returns http unprocessable entity" do
        patch book_path(book), params: { book: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns validation errors" do
        patch book_path(book), params: { book: invalid_attributes }
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end

    it "returns 404 for non-existent book" do
      patch book_path(999), params: { book: valid_attributes }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /books/:id" do
    it "destroys the book" do
      book_to_delete = create(:book)
      expect {
        delete book_path(book_to_delete)
      }.to change(Book, :count).by(-1)
    end

    it "returns http no content" do
      delete book_path(book)
      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 for non-existent book" do
      delete book_path(999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /books/:id/borrow" do
    let(:available_book) { create(:book, available: true, total_copies: 2) }
    let(:unavailable_book) { create(:book, available: false, total_copies: 1) }

    context "when book is available" do
      it "creates a new borrow record" do
        expect {
          post borrow_book_path(available_book)
        }.to change(Borrow, :count).by(1)
      end

      it "returns http created" do
        post borrow_book_path(available_book)
        expect(response).to have_http_status(:created)
      end

      it "creates borrow with correct attributes" do
        post borrow_book_path(available_book)
        borrow = Borrow.last
        expect(borrow.borrower).to eq(user)
        expect(borrow.book).to eq(available_book)
        expect(borrow.returned).to be false
        expect(borrow.borrowed_at).to be_present
        expect(borrow.due_at).to be_present
      end

      it "sets due date to 2 weeks from now" do
        post borrow_book_path(available_book)
        borrow = Borrow.last
        expect(borrow.due_at).to be_within(1.minute).of(2.weeks.from_now)
      end
    end

    context "when book is not available" do
      it "does not create a borrow record" do
        expect {
          post borrow_book_path(unavailable_book)
        }.not_to change(Borrow, :count)
      end

      it "returns http unprocessable entity" do
        post borrow_book_path(unavailable_book)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns validation errors" do
        post borrow_book_path(unavailable_book)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end

    context "when user already borrowed the same book" do
      before do
        create(:borrow, borrower: user, book: available_book, returned: false)
      end

      it "does not create a new borrow record" do
        expect {
          post borrow_book_path(available_book)
        }.not_to change(Borrow, :count)
      end

      it "returns http unprocessable entity" do
        post borrow_book_path(available_book)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns validation errors" do
        post borrow_book_path(available_book)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end

    context "when book does not exist" do
      it "returns 404" do
        post borrow_book_path(999)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when not authenticated" do
      before do
        sign_out user
      end

      it "returns unauthorized" do
        post borrow_book_path(available_book)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "Authorization" do
    context "when not authenticated" do
      before do
        sign_out user
      end

      it "redirects to login for index" do
        get books_path
        expect(response).to have_http_status(:unauthorized)
      end

      it "redirects to login for show" do
        get book_path(book)
        expect(response).to have_http_status(:unauthorized)
      end

      it "redirects to login for create" do
        post books_path, params: { book: valid_attributes }
        expect(response).to have_http_status(:unauthorized)
      end

      it "redirects to login for update" do
        patch book_path(book), params: { book: valid_attributes }
        expect(response).to have_http_status(:unauthorized)
      end

      it "redirects to login for destroy" do
        delete book_path(book)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
