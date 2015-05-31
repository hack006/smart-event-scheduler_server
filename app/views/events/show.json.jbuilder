json.id @event.friendly_id
json.extract! @event,
              :name,
              :description
json.managerId @event.manager_id
json.votingDeadline @event.voting_deadline.iso8601
json.createdAt @event.created_at.iso8601
json.updatedAt @event.updated_at.iso8601

json.times @event.times do |time|
  json.extract! time, :id
  json.from time.from.iso8601
  json.until time.until.iso8601
  json.durationType time.duration_type
end

json.activities @event.activities do |activity|
  json.extract! activity, :id, :name, :icon
  json.price activity.price
  json.priceUnit activity.price_unit
  json.pricePerUnit activity.price_per_unit
end

json.slots @grouped_slots_by_time do |time_slots|
  json.timeDetailId time_slots[:time_detail_id]
  json.activities time_slots[:activities] do |activity_slot|
    json.id activity_slot[:id]
    json.activityDetailId activity_slot[:activity_detail_id]
    json.note activity_slot[:note]
  end
end