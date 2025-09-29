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
      response_data = JSON.parse(response.body)
      expect(response_data['data'].length).to eq(3)
    end

    describe "role-based serialization" do
      let!(:book1) { create(:book, title: "Book 1") }
      let!(:book2) { create(:book, title: "Book 2") }
      let!(:member_user) { create(:user, role: 'member') }
      let!(:librarian_user) { create(:user, role: 'librarian') }

      context "when user is a member" do
        before do
          sign_in member_user
        end

        it "returns books with standard serializer" do
          get books_path
          response_data = JSON.parse(response.body)
          books = response_data['data']
          
          expect(books.length).to eq(2)
          books.each do |book|
            expect(book).to have_key('id')
            expect(book).to have_key('type')
            expect(book['type']).to eq('book')
            attributes = book['attributes']
            expect(attributes).to have_key('title')
            expect(attributes).to have_key('author')
            expect(attributes).to have_key('genre')
            expect(attributes).to have_key('isbn')
            expect(attributes).to have_key('total_copies')
            expect(attributes).to have_key('available')
            expect(attributes).to have_key('created_at')
            expect(attributes).to have_key('updated_at')
            expect(attributes).not_to have_key('borrows')
          end
        end
      end

      context "when user is a librarian" do
        before do
          sign_in librarian_user
        end

        it "returns books with librarian serializer including borrows" do
          get books_path
          response_data = JSON.parse(response.body)
          books = response_data['data']
          
          expect(books.length).to eq(2)
          books.each do |book|
            expect(book).to have_key('id')
            expect(book).to have_key('type')
            expect(book['type']).to eq('librarian_book')
            attributes = book['attributes']
            expect(attributes).to have_key('title')
            expect(attributes).to have_key('author')
            expect(attributes).to have_key('genre')
            expect(attributes).to have_key('isbn')
            expect(attributes).to have_key('total_copies')
            expect(attributes).to have_key('available')
            expect(attributes).to have_key('created_at')
            expect(attributes).to have_key('updated_at')
            expect(attributes).to have_key('borrows')
            expect(attributes['borrows']).to be_an(Array)
          end
        end

        context "when books have borrows" do
          let!(:book1_with_copies) { create(:book, title: "Book 1", total_copies: 2) }
          let!(:borrower1) { create(:user, name: "John Doe", email: "john@example.com") }
          let!(:borrower2) { create(:user, name: "Jane Smith", email: "jane@example.com") }
          let!(:borrow1) { create(:borrow, book: book1_with_copies, borrower: borrower1, returned: false) }
          let!(:borrow2) { create(:borrow, book: book1_with_copies, borrower: borrower2, returned: true) }
          let!(:borrow3) { create(:borrow, book: book2, borrower: borrower1, returned: false) }

          it "includes not returned borrows information for each book" do
            get books_path
            response_data = JSON.parse(response.body)
            books = response_data['data']
            
            book1_data = books.find { |b| b['id'] == book1_with_copies.id.to_s }
            book2_data = books.find { |b| b['id'] == book2.id.to_s }
            
            # Book 1 should have 2 borrows (1 not returned, 1 returned), count just not returned 
            expect(book1_data['attributes']['borrows'].length).to eq(1)
            
            # Book 2 should have 1 borrow (not returned)
            expect(book2_data['attributes']['borrows'].length).to eq(1)
            
            # Check borrow structure
            borrow_data = book1_data['attributes']['borrows'].first
            expect(borrow_data).to have_key('id')
            expect(borrow_data).to have_key('borrower_id')
            expect(borrow_data).to have_key('borrower_name')
            expect(borrow_data).to have_key('borrower_email')
            expect(borrow_data).to have_key('borrowed_at')
            expect(borrow_data).to have_key('due_at')
            expect(borrow_data).to have_key('returned')
            expect(borrow_data).to have_key('created_at')
            expect(borrow_data).to have_key('updated_at')
          end
        end

        context "when books have no borrows" do
          it "returns empty borrows array" do
            get books_path
            response_data = JSON.parse(response.body)
            books = response_data['data']
            
            books.each do |book|
              expect(book['attributes']['borrows']).to eq([])
            end
          end
        end
      end
    end

    describe "search" do
      let!(:book1) { create(:book, title: "The Great Gatsby", author: "F. Scott Fitzgerald", genre: "Fiction") }
      let!(:book2) { create(:book, title: "1984", author: "George Orwell", genre: "Dystopian Fiction") }
      let!(:book3) { create(:book, title: "Pride and Prejudice", author: "Jane Austen", genre: "Romance") }
      let!(:book4) { create(:book, title: "The Hobbit", author: "J.R.R. Tolkien", genre: "Fantasy") }

      context "when searching by title" do
        it "returns books matching the title" do
          get books_path, params: { search: "Gatsby" }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(1)
          expect(books.first['attributes']['title']).to eq("The Great Gatsby")
        end

        it "returns books with partial title match" do
          get books_path, params: { search: "Great" }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(1)
          expect(books.first['attributes']['title']).to eq("The Great Gatsby")
        end

        it "is case insensitive" do
          get books_path, params: { search: "gatsby" }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(1)
          expect(books.first['attributes']['title']).to eq("The Great Gatsby")
        end
      end

      context "when searching by author" do
        it "returns books matching the author" do
          get books_path, params: { search: "Orwell" }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(1)
          expect(books.first['attributes']['author']).to eq("George Orwell")
        end

        it "returns books with partial author match" do
          get books_path, params: { search: "George" }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(1)
          expect(books.first['attributes']['author']).to eq("George Orwell")
        end

        it "is case insensitive" do
          get books_path, params: { search: "orwell" }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(1)
          expect(books.first['attributes']['author']).to eq("George Orwell")
        end
      end

      context "when searching by genre" do
        it "returns books matching the genre" do
          get books_path, params: { search: "Fiction" }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(2)
          expect(books.map { |b| b['attributes']['title'] }).to contain_exactly("The Great Gatsby", "1984")
        end

        it "returns books with partial genre match" do
          get books_path, params: { search: "Fantasy" }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(1)
          expect(books.first['attributes']['title']).to eq("The Hobbit")
        end

        it "is case insensitive" do
          get books_path, params: { search: "fiction" }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(2)
        end
      end

      context "when searching across multiple fields" do
        it "returns books matching any field" do
          get books_path, params: { search: "Jane" }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(1)
          expect(books.first['attributes']['author']).to eq("Jane Austen")
        end

        it "returns multiple books when search term matches multiple fields" do
          # Create a book where title contains "The" and another where author contains "The"
          create(:book, title: "The Road", author: "Cormac McCarthy", genre: "Post-Apocalyptic")
          get books_path, params: { search: "The" }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(3) # The Great Gatsby, The Hobbit, The Road
        end
      end

      context "when no search results found" do
        it "returns empty array" do
          get books_path, params: { search: "NonExistentBook" }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(0)
        end
      end

      context "when search parameter is empty" do
        it "returns all books" do
          get books_path, params: { search: "" }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(4)
        end
      end

      context "when search parameter is nil" do
        it "returns all books" do
          get books_path, params: { search: nil }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(4)
        end
      end

      context "when no search parameter provided" do
        it "returns all books" do
          get books_path
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(4)
        end
      end

      context "when searching with special characters" do
        let!(:special_book) { create(:book, title: "The Cat's Cradle", author: "Kurt Vonnegut", genre: "Science Fiction") }

        it "handles apostrophes in search" do
          get books_path, params: { search: "Cat's" }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(1)
          expect(books.first['attributes']['title']).to eq("The Cat's Cradle")
        end

        it "handles apostrophes in partial search" do
          get books_path, params: { search: "Cat" }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(1)
          expect(books.first['attributes']['title']).to eq("The Cat's Cradle")
        end
      end

      context "when searching with whitespace" do
        it "trims whitespace and searches" do
          get books_path, params: { search: "  Gatsby  " }
          response_data = JSON.parse(response.body)
          books = response_data['data']
          expect(books.length).to eq(1)
          expect(books.first['attributes']['title']).to eq("The Great Gatsby")
        end
      end

      context "role-based search results" do
        let!(:member_user) { create(:user, role: 'member') }
        let!(:librarian_user) { create(:user, role: 'librarian') }
        let!(:borrower) { create(:user, name: "Test Borrower") }
        let!(:borrow) { create(:borrow, book: book1, borrower: borrower, returned: false) }

        context "when member searches" do
          before do
            sign_in member_user
          end

          it "returns search results without borrows information" do
            get books_path, params: { search: "Gatsby" }
            response_data = JSON.parse(response.body)
            books = response_data['data']
            
            expect(books.length).to eq(1)
            expect(books.first['attributes']).to have_key('title')
            expect(books.first['attributes']).not_to have_key('borrows')
          end
        end

        context "when librarian searches" do
          before do
            sign_in librarian_user
          end

          it "returns search results with borrows information" do
            get books_path, params: { search: "Gatsby" }
            response_data = JSON.parse(response.body)
            books = response_data['data']
            
            expect(books.length).to eq(1)
            expect(books.first['attributes']).to have_key('title')
            expect(books.first['attributes']).to have_key('borrows')
            expect(books.first['attributes']['borrows']).to be_an(Array)
            expect(books.first['attributes']['borrows'].length).to eq(1)
            expect(books.first['attributes']['borrows'].first['borrower_name']).to eq("Test Borrower")
          end
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
      response_data = JSON.parse(response.body)
      expect(response_data['data']['id']).to eq(book.id.to_s)
    end

    it "returns 404 for non-existent book" do
      get book_path(999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /books" do
    let(:librarian_user) { create(:user, role: 'librarian') }
    
    before do
      sign_in librarian_user
    end
    
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
        response_data = JSON.parse(response.body)
        expect(response_data['data']['attributes']['title']).to eq(valid_attributes[:title])
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
    let(:librarian_user) { create(:user, role: 'librarian') }
    
    before do
      sign_in librarian_user
    end
    
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
        response_data = JSON.parse(response.body)
        expect(response_data['data']['attributes']['title']).to eq('Updated Title')
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
    let(:librarian_user) { create(:user, role: 'librarian') }
    
    before do
      sign_in librarian_user
    end
    
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
    let(:member_user) { create(:user, role: 'member') }
    let(:librarian_user) { create(:user, role: 'librarian') }

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

    context "role-based authorization" do
      describe "for member users" do
        before do
          sign_in member_user
        end

        it "allows reading books" do
          get books_path
          expect(response).to have_http_status(:success)
        end

        it "allows showing individual books" do
          get book_path(book)
          expect(response).to have_http_status(:success)
        end

        it "allows borrowing books" do
          post borrow_book_path(book)
          expect(response).to have_http_status(:created)
        end

        it "denies creating books" do
          post books_path, params: { book: valid_attributes }
          expect(response).to have_http_status(:forbidden)
        end

        it "denies updating books" do
          patch book_path(book), params: { book: valid_attributes }
          expect(response).to have_http_status(:forbidden)
        end

        it "denies destroying books" do
          delete book_path(book)
          expect(response).to have_http_status(:forbidden)
        end
      end

      describe "for librarian users" do
        before do
          sign_in librarian_user
        end

        it "allows reading books" do
          get books_path
          expect(response).to have_http_status(:success)
        end

        it "allows showing individual books" do
          get book_path(book)
          expect(response).to have_http_status(:success)
        end

        it "allows borrowing books" do
          post borrow_book_path(book)
          expect(response).to have_http_status(:created)
        end

        it "allows creating books" do
          post books_path, params: { book: valid_attributes }
          expect(response).to have_http_status(:created)
        end

        it "allows updating books" do
          patch book_path(book), params: { book: valid_attributes }
          expect(response).to have_http_status(:success)
        end

        it "allows destroying books" do
          delete book_path(book)
          expect(response).to have_http_status(:no_content)
        end
      end
    end
  end
end
