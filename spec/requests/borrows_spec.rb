require 'rails_helper'

RSpec.describe "Borrows", type: :request do
  let(:user) { create(:user) }
  let(:book) { create(:book, available: true, total_copies: 1) }
  let(:borrow) { create(:borrow, borrower: user, book: book, returned: false) }

  before do
    sign_in user
  end

  describe "PATCH /borrows/:id" do
    context "when updating to returned" do
      it "updates the borrow record" do
        patch borrow_path(borrow), params: { borrow: { returned: true } }
        borrow.reload
        expect(borrow.returned).to be true
      end

      it "returns http success" do
        patch borrow_path(borrow), params: { borrow: { returned: true } }
        expect(response).to have_http_status(:success)
      end

      it "returns the updated borrow" do
        patch borrow_path(borrow), params: { borrow: { returned: true } }
        expect(JSON.parse(response.body)['returned']).to be true
      end

      it "updates book availability when returned" do
        book.reload
        expect(book.available).to be false
        
        patch borrow_path(borrow), params: { borrow: { returned: true } }
        book.reload
        expect(book.available).to be true
      end
    end

    context "when updating other fields" do
      it "updates the borrow record" do
        new_due_date = 1.week.from_now
        patch borrow_path(borrow), params: { borrow: { due_at: new_due_date } }
        borrow.reload
        expect(borrow.due_at).to be_within(1.minute).of(new_due_date)
      end

      it "returns http success" do
        patch borrow_path(borrow), params: { borrow: { due_at: 1.week.from_now } }
        expect(response).to have_http_status(:success)
      end
    end

    context "when borrow does not exist" do
      it "returns 404" do
        patch borrow_path(999), params: { borrow: { returned: true } }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when not authenticated" do
      before do
        sign_out user
      end

      it "returns unauthorized" do
        patch borrow_path(borrow), params: { borrow: { returned: true } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
