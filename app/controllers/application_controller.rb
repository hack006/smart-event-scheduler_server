class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_user!

  def must_be_logged_in
    if current_user.blank?
      respond_to do |format|
         format.json { render json: { message: 'You have to be logged in for this action!'}, status: :unauthorized }
      end
    end

  end
end
