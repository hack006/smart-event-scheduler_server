class EventsController < ApplicationController
  before_action :set_event, only: [:update, :destroy]

  respond_to :json

  # /events/my
  def my_events
    @events = Event.where(manager_id: current_user.id).all
    respond_with(@events)
  end

  def create
    @event = Event.new(event_params)
    @event.save
    respond_with(@event)
  end

  def update
    @event.update(event_params)
    respond_with(@event)
  end

  def destroy
    @event.destroy
    respond_with(@event)
  end

  private
  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :description, :voting_deadline)
  end
end
