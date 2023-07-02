class BookReviewsController < ApplicationController
  skip_before_action :authenticate, only: :index

  # Get all reviews for a specific book
  def index
    book_id = params[:book_id]
    book_reviews = BookReview.where(book_id: book_id).pluck(:id, :user_id, :user_username, :review)

    render json: book_reviews
  end

  # Create a new review for a book
  def create
    book_id = params[:book_id]
    user_id = Current.user.id
    user_username = Current.user.username
    book_review = params[:review]

    review = BookReview.create(user_id: user_id, book_id: book_id, user_username: user_username, review: book_review)
    review_id = review.id

    render json: { message: "Review stored successfully", review_id: review_id }
  end

  # Delete a review
  def destroy
    review_id = params[:id]
    relation = BookReview.find_by(id: review_id)

    if relation
      relation.destroy
      render json: { message: "Review deleted successfully" }
    else
      render json: { error: "Review not found" }, status: :unprocessable_entity
    end
  end
end
