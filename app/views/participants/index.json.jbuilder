json.array!(@participants) do |participant|
  json.extract! participant, :id, :note, :user_id
  json.url participant_url(participant, format: :json)
end
