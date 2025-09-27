FactoryBot.define do
  factory :borrow do
    association :borrower, factory: :user
    association :book
    borrowed_at { Time.current }
    due_at { 2.weeks.from_now }
    returned { false }
  end
end
