json.array!(@my_events) do |my_event|
  json.id my_event.friendly_id
  json.extract! my_event, :name, :description
  json.votingDeadline my_event.voting_deadline
  json.createdAt my_event.created_at
  json.updatedAt my_event.updated_at
  json.url event_url(my_event, format: :json)
end
