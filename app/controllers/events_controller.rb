class EventsController < ApplicationController
  before_action :set_event, only: [:show, :update, :destroy]

  respond_to :json

  # /events/my
  def my_events
    @my_events = Event.where(manager_id: current_user.id).all
    respond_with(@my_events)
  end

  def show
    respond_with(@event)
  end

  def create
    # TODO authorize

    @event = Event.new(event_params)
    @event.manager_id = current_user.id
    @event.save
    respond_with @event, template: 'events/show'
  end

  def update
    @event.update(event_params)
    respond_with @event, template: 'events/show'
  end

  def destroy
    @event.destroy
    respond_with(@event)
  end

  private
  def set_event
    @event = Event.friendly.find(params[:id])
  end

  def event_params
    params.permit(:name, :description, :voting_deadline)
  end
end
