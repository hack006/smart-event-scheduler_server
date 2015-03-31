json.id @event.friendly_id
json.extract! @event,
              :name,
              :description
json.managerId @event.manager_id
json.votingDeadline @event.voting_deadline.iso8601
json.createdAt @event.created_at.iso8601
json.updatedAt @event.updated_at.iso8601