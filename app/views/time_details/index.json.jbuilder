json.array!(@time_details) do |time_detail|
  json.extract! time_detail, :id, :from, :until, :duration_type
  json.url time_detail_url(time_detail, format: :json)
end
