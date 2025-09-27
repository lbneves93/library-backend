class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  
  devise :database_authenticatable, :registerable, :recoverable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self
  
  enum :role, { member: 0, librarian: 1 }, validate: true

  # Borrow relationships
  has_many :borrows, foreign_key: 'borrower_id'
  has_many :books, through: :borrows
end
