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
    # get all event
    @grouped_slots_by_time = []

    @event.times.each do |time|
      activity_slots_for_time = @event.slots.where('time_detail_id = ?', time.id)

      slots_with_time = {time_detail_id: time.id, activities: []}

      activity_slots_for_time.each do |activity_slot|
        slots_with_time[:activities] << {id: activity_slot.id, activity_detail_id: activity_slot.activity_detail_id, note: activity_slot.note}
      end

      @grouped_slots_by_time << slots_with_time
    end

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
          @event.update_attributes!(event_params)
        else
          @event = Event.friendly.find(params[:id])
          @event.update_attributes!(event_params)
        end

        @event.save!

        # Activities / places
        existing_activity_ids = []
        @event.activities.select(:id).each { |a| existing_activity_ids.push a.id }

        unless params[:activities].blank?
          params[:activities].each do |activity_params|
            trusted_activity_params = activity_params(activity_params)
            if activity_params[:id].blank?
              @activity = ActivityDetail.new(trusted_activity_params)
              @activity.event_id = @event.id
            else
              @activity = @event.activities.find(activity_params[:id])
              if @activity.present?
                existing_activity_ids.delete(@activity.id)
                @activity.update_attributes(trusted_activity_params)
              end
            end
            @activity.save!
          end
        end

        @event.activities.where('id IN (?)', existing_activity_ids).destroy_all


        # Times
        existing_time_ids = []
        @event.times.select(:id).each { |t| existing_time_ids.push t.id }

        unless params[:times].blank?
          params[:times].each do |time_params|
            trusted_time_params = time_params(time_params)
            if time_params[:id].blank?
              @time = TimeDetail.new(trusted_time_params)
              @time.event_id = @event.id
            else
              @time = @event.times.find(time_params[:id])
              if @time.present?
                existing_time_ids.delete(@time.id)
                @time.update_attributes(trusted_time_params)
              end
            end
            @time.save!
          end
        end

        @event.times.where('id IN (?)', existing_time_ids).destroy_all

        # Slots
        existing_slot_ids = []
        @event.slots.select(:id).each { |t| existing_slot_ids.push t.id }

        unless params[:slots].blank?
          params[:slots].each do |slot_per_times_params|
            unless slot_per_times_params[:activities].blank?
              slot_per_times_params[:activities].each do |slot_params|
                trusted_slot_params = slot_params(slot_params)
                if slot_params[:id].blank?
                  activity_id = slot_params[:activity_detail_id]
                  time_id = slot_per_times_params[:time_detail_id]

                  if activity_id.blank? || existing_activity_ids.include?(activity_id) || time_id.blank? || existing_time_ids.include?(time_id)
                    raise 'Unknown activity or time id!'
                  end
                  @slot = Slot.new(trusted_slot_params)
                  @slot.event_id = @event.id
                  @slot.activity_detail_id = activity_id
                  @slot.time_detail_id = time_id
                else
                  @slot = @event.slots.find(slot_params[:id])
                  if @slot.present?
                    existing_slot_ids.delete(@slot.id)
                    @slot.update_attributes(trusted_slot_params)
                  end
                end
                @slot.save!
              end
            end
          end
        end

        @event.slots.where('id IN (?)', existing_slot_ids).destroy_all # TODO rename

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
    params.permit(:name, :icon, :price, :price_unit, :price_per_unit)
  end

  def slot_params(params)
    params.permit(:note)
  end
end
