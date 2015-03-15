json.array!(@my_events) do |my_event|
  json.id my_event.friendly_id
  json.extract! my_event, :name, :description, :voting_deadline, :created_at, :updated_at
  json.url event_url(my_event, format: :json)
end
