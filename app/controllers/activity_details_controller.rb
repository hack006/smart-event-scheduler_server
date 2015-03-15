class ActivityDetailsController < ApplicationController
  before_action :set_activity_detail, only: [:show, :edit, :update, :destroy]
  before_action :set_event

  respond_to :json

  # /event/:event_id/activities
  def event_activities
    @activities = ActivityDetail.joins(:slots)
                        .joins(:events)
                        .where('event.id = ?', @event.id)
                        .uniq
    respond_with(@activities)
  end

  def create
    @activity_detail = ActivityDetail.new(activity_detail_params)
    @activity_detail.save
    respond_with(@activity_detail)
  end

  def update
    @activity_detail.update(activity_detail_params)
    respond_with(@activity_detail)
  end

  def destroy
    @activity_detail.destroy
    respond_with(@activity_detail)
  end

  private
    def set_activity_detail
      @activity_detail = ActivityDetail.find(params[:id])
    end

    def set_event
      @event = Event.find(params[:event_id])
    end

    def activity_detail_params
      params.require(:activity_detail).permit(:event_id, :name, :icon, :price, :price_per_unit, :icon)
    end
end
