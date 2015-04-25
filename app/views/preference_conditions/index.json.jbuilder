json.array!(@preference_conditions) do |preference|
  json.id preference.id,
  json.conditionType preference.condition_type
  json.participationOwnerId preference.participant_id
  json.participant1Id preference.participant1_id
  json.participant2Id preference.participant2_id

  json.url preference_condition_url(preference, format: :json)
end
