class AvailabilitiesController < ApplicationController
  before_action :set_availability, only: [:show, :edit, :update, :destroy]

  respond_to :json

  # /event/:event_id/user/:user_id/availability
  def index
    @event = Event.find(params[:event_id])
    @participant = @event.participants.where(user_id: params[:user_id]).first
    @availabilities = @participant.availabilities

    respond_with(@availabilities)
  end

  def create
    @availability = Availability.new(availability_params)
    @availability.save
    respond_with(@availability)
  end

  def update
    @availability.update(availability_params)
    respond_with(@availability)
  end

  def destroy
    @availability.destroy
    respond_with(@availability)
  end

  private
    def set_availability
      @availability = Availability.find(params[:id])
    end

    def availability_params
      params.require(:availability).permit(:status)
    end
end
