json.array!(@preference_prioritizations) do |preference_prioritization|
  json.extract! preference_prioritization, :id, :participant_id, :for_participant_id, :multiplier
  json.url preference_prioritization_url(preference_prioritization, format: :json)
end
