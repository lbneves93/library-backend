class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book, only: [:show, :update, :destroy]

  # GET /books
  def index
    @books = Book.all
    
    # Search functionality
    if params[:search].present?
      search_term = params[:search].strip.downcase
      @books = @books.where(
        "LOWER(title) LIKE ? OR LOWER(author) LIKE ? OR LOWER(genre) LIKE ?",
        "%#{search_term}%", "%#{search_term}%", "%#{search_term}%"
      )
    end
    
    render json: @books, each_serializer: BookSerializer
  end

  # GET /books/:id
  def show
    render json: @book, serializer: BookSerializer
  end

  # POST /books
  def create
    @book = Book.new(book_params)
    
    if @book.save
      render json: @book, serializer: BookSerializer, status: :created
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /books/:id
  def update
    if @book.update(book_params)
      render json: @book, serializer: BookSerializer
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /books/:id
  def destroy
    @book.destroy
    head :no_content
  end

  # POST /books/:id/borrow
  def borrow
    @book = Book.find(params[:id])
    
    @borrow = Borrow.new(
      borrower: current_user,
      book: @book,
      borrowed_at: Time.current,
      due_at: 2.weeks.from_now,
      returned: false
    )
    
    if @borrow.save
      render json: @borrow, status: :created
    else
      render json: { errors: @borrow.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Book not found' }, status: :not_found
  end

  private

  def set_book
    @book = Book.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Book not found' }, status: :not_found
  end

  def book_params
    params.require(:book).permit(:title, :author, :genre, :isbn, :total_copies)
  end
end
