class DashboardController < ApplicationController
  before_action :authenticate_user!

  # GET /dashboard
  def report
    if current_user.librarian?
      render_librarian_dashboard
    else
      render_member_dashboard
    end
  end

  private

  def render_librarian_dashboard
    dashboard_data = {
      total_books: Book.count,
      total_borrowed_books: Borrow.where(returned: false).count,
      books_due_today: books_due_today_count,
      overdue_members: overdue_members_list
    }
    
    render json: dashboard_data
  end

  def render_member_dashboard
    user_borrows = current_user.borrows.includes(:book).where(returned: false)
    
    borrowed_books = user_borrows.map do |borrow|
      {
        id: borrow.id,
        book: {
          id: borrow.book.id,
          title: borrow.book.title,
          author: borrow.book.author,
          genre: borrow.book.genre,
          isbn: borrow.book.isbn
        },
        borrowed_at: borrow.borrowed_at,
        due_at: borrow.due_at,
        days_until_due: days_until_due(borrow.due_at)
      }
    end
    
    render json: { borrowed_books: borrowed_books }
  end

  def books_due_today_count
    Borrow.where(returned: false)
          .where(due_at: Date.current.beginning_of_day..Date.current.end_of_day)
          .count
  end

  def overdue_members_list
    overdue_borrows = Borrow.includes(:borrower, :book)
                            .where(returned: false)
                            .where('due_at < ?', Date.current.beginning_of_day)
    
    overdue_borrows.map do |borrow|
      {
        member_id: borrow.borrower.id,
        member_name: borrow.borrower.name,
        member_email: borrow.borrower.email,
        book_title: borrow.book.title,
        book_author: borrow.book.author,
        borrowed_at: borrow.borrowed_at,
        due_at: borrow.due_at,
        days_overdue: days_overdue(borrow.due_at)
      }
    end
  end

  def days_until_due(due_date)
    (due_date.to_date - Date.current).to_i
  end

  def days_overdue(due_date)
    (Date.current - due_date.to_date).to_i
  end
end
