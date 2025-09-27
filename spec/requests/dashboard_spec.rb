require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  let(:member_user) { create(:user, role: 'member', name: 'John Member', email: 'member@example.com') }
  let(:librarian_user) { create(:user, role: 'librarian', name: 'Jane Librarian', email: 'librarian@example.com') }

  before do
    sign_in member_user
  end

  describe "GET /dashboard" do
    it "returns http success" do
      get dashboard_path
      expect(response).to have_http_status(:success)
    end

    describe "for member users" do
      let!(:book1) { create(:book, title: "Book 1", author: "Author 1") }
      let!(:book2) { create(:book, title: "Book 2", author: "Author 2") }
      let!(:book3) { create(:book, title: "Book 3", author: "Author 3") }

      context "when member has borrowed books" do
        let!(:borrow1) { create(:borrow, borrower: member_user, book: book1, returned: false, due_at: 1.week.from_now) }
        let!(:borrow2) { create(:borrow, borrower: member_user, book: book2, returned: false, due_at: 2.weeks.from_now) }
        let!(:returned_borrow) { create(:borrow, borrower: member_user, book: book3, returned: true) }

        it "returns borrowed books for the member" do
          get dashboard_path
          response_data = JSON.parse(response.body)
          
          expect(response_data).to have_key('borrowed_books')
          expect(response_data['borrowed_books'].length).to eq(2)
        end

        it "includes correct book information" do
          get dashboard_path
          response_data = JSON.parse(response.body)
          borrowed_book = response_data['borrowed_books'].first
          
          expect(borrowed_book).to have_key('id')
          expect(borrowed_book).to have_key('book')
          expect(borrowed_book).to have_key('borrowed_at')
          expect(borrowed_book).to have_key('due_at')
          expect(borrowed_book).to have_key('days_until_due')
          
          expect(borrowed_book['book']).to have_key('id')
          expect(borrowed_book['book']).to have_key('title')
          expect(borrowed_book['book']).to have_key('author')
          expect(borrowed_book['book']).to have_key('genre')
          expect(borrowed_book['book']).to have_key('isbn')
        end

        it "calculates days until due correctly" do
          get dashboard_path
          response_data = JSON.parse(response.body)
          
          response_data['borrowed_books'].each do |borrow|
            expect(borrow['days_until_due']).to be_a(Integer)
            expect(borrow['days_until_due']).to be >= 0
          end
        end

        it "does not include returned books" do
          get dashboard_path
          response_data = JSON.parse(response.body)
          
          book_titles = response_data['borrowed_books'].map { |b| b['book']['title'] }
          expect(book_titles).not_to include("Book 3")
        end
      end

      context "when member has no borrowed books" do
        it "returns empty borrowed_books array" do
          get dashboard_path
          response_data = JSON.parse(response.body)
          
          expect(response_data['borrowed_books']).to eq([])
        end
      end
    end

    describe "for librarian users" do
      before do
        sign_in librarian_user
      end

      let!(:book1) { create(:book, title: "Book 1", author: "Author 1") }
      let!(:book2) { create(:book, title: "Book 2", author: "Author 2") }
      let!(:book3) { create(:book, title: "Book 3", author: "Author 3") }
      let!(:other_member) { create(:user, role: 'member', name: 'Other Member', email: 'other@example.com') }

      context "with various borrow scenarios" do
        let!(:active_borrow1) { create(:borrow, borrower: member_user, book: book1, returned: false, due_at: 1.week.from_now) }
        let!(:active_borrow2) { create(:borrow, borrower: other_member, book: book2, returned: false, due_at: 2.weeks.from_now) }
        let!(:returned_borrow) { create(:borrow, borrower: member_user, book: book3, returned: true) }
        let!(:due_today_borrow) { create(:borrow, borrower: other_member, book: book1, returned: false, due_at: Date.current) }
        let!(:overdue_borrow) { create(:borrow, borrower: member_user, book: book2, returned: false, due_at: 1.day.ago) }

        it "returns dashboard statistics" do
          get dashboard_path
          response_data = JSON.parse(response.body)
          
          expect(response_data).to have_key('total_books')
          expect(response_data).to have_key('total_borrowed_books')
          expect(response_data).to have_key('books_due_today')
          expect(response_data).to have_key('overdue_members')
        end

        it "calculates total books correctly" do
          get dashboard_path
          response_data = JSON.parse(response.body)
          
          expect(response_data['total_books']).to eq(3)
        end

        it "calculates total borrowed books correctly" do
          get dashboard_path
          response_data = JSON.parse(response.body)
          
          expect(response_data['total_borrowed_books']).to eq(3) # active_borrow1, active_borrow2, due_today_borrow, overdue_borrow
        end

        it "calculates books due today correctly" do
          get dashboard_path
          response_data = JSON.parse(response.body)
          
          expect(response_data['books_due_today']).to eq(1) # due_today_borrow
        end

        it "lists overdue members correctly" do
          get dashboard_path
          response_data = JSON.parse(response.body)
          
          expect(response_data['overdue_members'].length).to eq(1)
          overdue_member = response_data['overdue_members'].first
          
          expect(overdue_member).to have_key('member_id')
          expect(overdue_member).to have_key('member_name')
          expect(overdue_member).to have_key('member_email')
          expect(overdue_member).to have_key('book_title')
          expect(overdue_member).to have_key('book_author')
          expect(overdue_member).to have_key('borrowed_at')
          expect(overdue_member).to have_key('due_at')
          expect(overdue_member).to have_key('days_overdue')
          
          expect(overdue_member['member_name']).to eq('John Member')
          expect(overdue_member['book_title']).to eq('Book 2')
          expect(overdue_member['days_overdue']).to eq(1)
        end
      end

      context "with no borrows" do
        it "returns zero counts" do
          get dashboard_path
          response_data = JSON.parse(response.body)
          
          expect(response_data['total_books']).to eq(3)
          expect(response_data['total_borrowed_books']).to eq(0)
          expect(response_data['books_due_today']).to eq(0)
          expect(response_data['overdue_members']).to eq([])
        end
      end

      context "with multiple overdue members" do
        let!(:member2) { create(:user, role: 'member', name: 'Member 2', email: 'member2@example.com') }
        let!(:member3) { create(:user, role: 'member', name: 'Member 3', email: 'member3@example.com') }
        
        let!(:overdue1) { create(:borrow, borrower: member_user, book: book1, returned: false, due_at: 2.days.ago) }
        let!(:overdue2) { create(:borrow, borrower: member2, book: book2, returned: false, due_at: 3.days.ago) }
        let!(:overdue3) { create(:borrow, borrower: member3, book: book3, returned: false, due_at: 1.day.ago) }

        it "lists all overdue members" do
          get dashboard_path
          response_data = JSON.parse(response.body)
          
          expect(response_data['overdue_members'].length).to eq(3)
          
          member_names = response_data['overdue_members'].map { |m| m['member_name'] }
          expect(member_names).to include('John Member', 'Member 2', 'Member 3')
        end

        it "calculates days overdue correctly" do
          get dashboard_path
          response_data = JSON.parse(response.body)
          
          overdue_members = response_data['overdue_members']
          
          overdue_members.each do |member|
            expect(member['days_overdue']).to be > 0
          end
        end
      end
    end

    describe "authentication" do
      context "when not authenticated" do
        before do
          sign_out member_user
        end

        it "returns unauthorized" do
          get dashboard_path
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
