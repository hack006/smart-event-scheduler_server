class PreferencesController < ApplicationController
  before_action :set_preference, only: [:show, :edit, :update, :destroy]

  respond_to :json

  def index
    @preferences = Preference.all
    respond_with(@preferences)
  end

  def show
    respond_with(@preference)
  end

  def create
    @preference = Preference.new(preference_params)
    @preference.save
    respond_with(@preference)
  end

  def update
    @preference.update(preference_params)
    respond_with(@preference)
  end

  def destroy
    @preference.destroy
    respond_with(@preference)
  end

  private
    def set_preference
      @preference = Preference.find(params[:id])
    end

    def preference_params
      params.require(:preference).permit(:type, :user1_id, :user2_id, :multiplier)
    end
end
