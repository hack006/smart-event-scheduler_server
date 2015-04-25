json.id @event.friendly_id
json.extract! @event,
              :name,
              :description
json.managerId @event.manager_id
json.votingDeadline @event.voting_deadline.iso8601
json.createdAt @event.created_at.iso8601
json.updatedAt @event.updated_at.iso8601

json.times @event.times do |time|
  json.extract! time, :id, :from, :until
  json.durationType time.duration_type
end

json.activities @event.activities do |activity|
  json.extract! activity, :id, :name, :icon
  json.price activity.price
  json.pricePerUnit activity.price_per_unit
end

json.slots Hash.new