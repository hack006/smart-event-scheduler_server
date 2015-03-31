class TimeDetailsController < ApplicationController
  before_action :set_time_detail, only: [:show, :edit, :update, :destroy]
  before_action :set_event, only: [:event_times, :create]

  respond_to :json

  # /api1/event/:event_id/times
  def event_times
    @times = TimeDetail.joins(:slots)
                        .joins(:events)
                        .where('event.id = ?', @event.id)
                        .uniq
    respond_with(@times)
  end

  def create
    @time_detail = TimeDetail.new(time_detail_params)
    @time_detail.event = @event
    @time_detail.save
    respond_with(@time_detail)
  end

  def update
    @time_detail.update(time_detail_params)
    respond_with(@time_detail)
  end

  def destroy
    @time_detail.destroy
    respond_with(@time_detail)
  end

  private
    def set_time_detail
      @time_detail = TimeDetail.find(params[:id])
    end

    def set_event
      @event = Event.find(params[:event_id])
    end

    def time_detail_params
      params.require(:time_detail).permit(:from, :until, :duration_type)
    end
end
