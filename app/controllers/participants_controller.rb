class ParticipantsController < ApplicationController
  before_action :set_participant, only: [:show, :edit, :update, :destroy]

  respond_to :json

  def event_participants
    @event = Event.find(params[:event_id])

    @participants = @event.participants.all
    respond_with(@participants)
  end

  def show
    respond_with(@participant)
  end

  def create
    @participant = Participant.new(participant_params)
    @participant.user_id = current_user.id

    @participant.save
    respond_with(@participant)
  end

  def update
    @participant.update(participant_params)
    respond_with(@participant)
  end

  def destroy
    @participant.destroy
    respond_to
    respond_with(@participant)
  end

  private
    def set_participant
      @participant = Participant.find(params[:id])
    end

    def participant_params
      params.require(:participant).permit(:note) #TODO user_id
    end
end
