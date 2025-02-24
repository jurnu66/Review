class ReviewsController < ApplicationController
  before_action :require_login, only: [:new, :create]

  def new
    @movie = Movie.find(params[:movie_id])
    @review = @movie.reviews.build
  end

  def create
    @movie = Movie.find(params[:movie_id])
    @review = @movie.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to movie_path(@movie), notice: "Review added successfully!"
    else
      render :new
    end
  end

  def destroy
    @movie = Movie.find(params[:movie_id])
    @review = @movie.reviews.find(params[:id])

    if @review.user == current_user # เช็คว่าเป็นเจ้าของรีวิวหรือไม่
      @review.destroy
      redirect_to movie_path(@movie), notice: "Review deleted successfully."
    else
      redirect_to movie_path(@movie), alert: "You can only delete your own reviews."
    end
  end

  private

  def review_params
    params.require(:review).permit(:rating, :comments)
  end

  def require_login
    unless current_user
      redirect_to login_path, alert: "You must be logged in to write a review."
    end
  end
end