class BookSerializer < ActiveModel::Serializer
  attributes :id, :title, :author, :genre, :isbn, :total_copies, :available, :created_at, :updated_at
end
