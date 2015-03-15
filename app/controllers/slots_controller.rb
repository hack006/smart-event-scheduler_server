class SlotsController < ApplicationController
  before_action :set_slot, only: [:show, :edit, :update, :destroy]

  respond_to :json

  # /event/:event_id/slots
  def event_slots
    # todo format as time and inside activity
    @event = Event.find(params[:event_id])

    @slots = @event.slots
    respond_with(@slots)
  end

  def create
    @slot = Slot.new(slot_params)
    @slot.save
    respond_with(@slot)
  end

  def update #TODO dangerous situation!
    @slot.update(slot_params)
    respond_with(@slot)
  end

  def destroy #TODO dangerous situation!
    @slot.destroy
    respond_with(@slot)
  end

  private
    def set_slot
      @slot = Slot.find(params[:id])
    end

    def slot_params
      params.require(:slot).permit(:note)
    end
end
