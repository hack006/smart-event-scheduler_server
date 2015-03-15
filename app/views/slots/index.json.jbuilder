json.array!(@slots) do |slot|
  json.extract! slot, :id, :event_id, :note
  json.url slot_url(slot, format: :json)
end
