class BorrowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_borrow, only: [:update]
  
  # Authorization - only librarians can update borrows
  authorize_resource

  # PATCH /borrows/:id
  def update
    if @borrow.update(borrow_params)
      render json: @borrow, status: :ok
    else
      render json: { errors: @borrow.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_borrow
    @borrow = Borrow.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Borrow record not found' }, status: :not_found
  end

  def borrow_params
    params.require(:borrow).permit(:returned, :due_at)
  end
end
