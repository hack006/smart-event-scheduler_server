json.array!(@activity_details) do |activity_detail|
  json.extract! activity_detail, :id, :event_id, :name, :icon, :price, :price_per_unit, :icon
  json.url activity_detail_url(activity_detail, format: :json)
end
