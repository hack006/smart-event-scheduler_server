class PreferencePrioritizationsController < ApplicationController
  before_action :set_preference_prioritization, only: [:show, :edit, :update, :destroy]

  respond_to :json

  def index
    @preference_prioritizations = PreferencePrioritization.all
    respond_with(@preference_prioritizations)
  end

  def show
    respond_with(@preference_prioritization)
  end

  def create
    @preference_prioritization = PreferencePrioritization.new(preference_prioritization_params)
    @preference_prioritization.save
    respond_with(@preference_prioritization)
  end

  def update
    @preference_prioritization.update(preference_prioritization_params)
    respond_with(@preference_prioritization)
  end

  def destroy
    @preference_prioritization.destroy
    respond_with(@preference_prioritization)
  end

  private
    def set_preference_prioritization
      @preference_prioritization = PreferencePrioritization.find(params[:id])
    end

    def preference_prioritization_params
      params.require(:preference_prioritization).permit(:participant_id, :for_participant_id, :multiplier)
    end
end
