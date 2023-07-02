class BooksController < ApplicationController

  # Get all book IDs stored by the current user
  def index
    user_id = Current.user.id
    book_ids = BookUserRelations.where(user_id: user_id).pluck(:book_id)

    render json: book_ids
  end

  # Store a book for the current user
  def create
    book_id = request[:book_id]
    user_id = Current.user.id 

    if BookUserRelations.exists?(user_id: user_id, book_id: book_id)
      render json: { error: "This book is already stored" }, status: :unprocessable_entity
    else
      BookUserRelations.create(user_id: user_id, book_id: book_id)
      render json: { message: "Book stored successfully" }
    end
  end

  # Remove a book from the current user's stored books
  def destroy
    user_id = Current.user.id 
    book_id = params[:id] 

    relation = BookUserRelations.find_by(user_id: user_id, book_id: book_id)
    if relation
      relation.destroy
      render json: { message: "Book deleted successfully" }
    else
      render json: { error: "Book not found" }, status: :unprocessable_entity
    end
  end
end
