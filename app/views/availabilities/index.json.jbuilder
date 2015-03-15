json.array!(@availabilities) do |availability|
  json.extract! availability, :id, :status
  json.url availability_url(availability, format: :json)
end
