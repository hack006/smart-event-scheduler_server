class PreferenceConditionsController < ApplicationController
  before_action :set_preference, only: [:show, :edit, :update, :destroy]

  respond_to :json

  def index
    @preference_conditions = PreferenceCondition.all
    respond_with(@preference_conditions)
  end

  def show
    respond_with(@preference_condition)
  end

  def create
    @preference_condition = PreferenceCondition.new(preference_params)
    @preference_condition.save
    respond_with(@preference_condition)
  end

  def update
    @preference_condition.update(preference_params)
    respond_with(@preference_condition)
  end

  def destroy
    @preference_condition.destroy
    respond_with(@preference_condition)
  end

  private
    def set_preference
      @preference_condition = PreferenceCondition.find(params[:id])
    end

    def preference_params
      params.require(:preference_condition).permit(:condition_type, :participant1_id, :participant2_id)
    end
end
