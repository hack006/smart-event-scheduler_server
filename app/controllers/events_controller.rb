module EVENT_TIMES
  CURRENT = 'CURRENT'
  PAST = 'PAST'
end

class EventsController < ApplicationController
  before_action :set_event, only: [:show, :update, :destroy]

  respond_to :json

  # /events/my
  def my_events
    limit = params[:limit].to_i || 100
    limit_count = params[:limitCount].to_i || 1
    time_of_events = params[:timeOfEvents]

    @my_events = Event.where(manager_id: current_user.id).limit(limit*limit_count)
    if time_of_events.present?
      time_filter_clause = 'voting_deadline '
      time_filter_clause += '>= ?' if time_of_events == EVENT_TIMES::CURRENT
      time_filter_clause += '<= ?' if time_of_events == EVENT_TIMES::PAST

      @my_events = @my_events.where(time_filter_clause, Time::current)
    end

    respond_with(@my_events.all)
  end

  def show
    respond_with(@event)
  end

  def create
    # TODO authorize
    begin
      Event.transaction do
        # raise ActiveRecord::Rollback
        if params[:id].blank?
          @event = Event.new
          @event.manager_id = current_user.id
          @event.create(event_params)
        else
          @event = Event.friendly.find(params[:id])
          @event.update(event_params)
        end

        @event.save!

        # Activities / places
        unless params[:activities].blank?
          existing_activity_ids = []
          @event.activities.select(:id).each {|a| existing_activity_ids.push a.id}

          params[:activities].each do |activity_params|
            trusted_activity_params = activity_params(activity_params)
            if activity_params[:id].blank?
              @activity = ActivityDetail.new(trusted_activity_params)
              @activity.event_id = @event.id
            else
              @activity = @event.activities.find(activity_params[:id])
              if @activity.present?
                existing_activity_ids.delete(@activity.id)
                @activity.update(trusted_activity_params)
              end
            end
            @activity.save!
          end
          @event.activities.where('id IN (?)', existing_activity_ids).destroy_all
        end


        # Times
        unless params[:times].blank?
          existing_time_ids = []
          @event.times.select(:id).each {|t| existing_time_ids.push t.id}

          params[:times].each do |time_params|
            trusted_time_params = time_params(time_params)
            if time_params[:id].blank?
              @time = TimeDetail.new(trusted_time_params)
              @time.event_id = @event.id
            else
              @time = @event.times.find(time_params[:id])
              if @time.present?
                existing_time_ids.delete(@time.id)
                @time.update(trusted_time_params)
              end
            end
            @time.save!
          end
          @event.times.where('id IN (?)', existing_time_ids).destroy_all
        end

        # TODO delete all from existing activity ids

      end
    rescue ActiveRecord::Rollback => e
      respond_with json: {message: 'Error while saving to database'}, :status => :unprocessable_entity
      return
    end

    respond_with @event
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

  def time_params(params)
    params.permit(:from, :until)
  end

  def activity_params(params)
    params.permit(:name, :icon, :price, :price_per_unit)
  end
end
