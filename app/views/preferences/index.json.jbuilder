json.array!(@preferences) do |preference|
  json.extract! preference, :id, :type, :user1_id, :user2_id, :multiplier
  json.url preference_url(preference, format: :json)
end
