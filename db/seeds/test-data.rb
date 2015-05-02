person_hash = {password: '12345678', password_confirmation: '12345678'}
john = User.create!(person_hash.merge({name: 'John', email: 'john@example.com'}))
jamie = User.create!(person_hash.merge({name: 'Jamie', email: 'jamie@example.com'}))
peter = User.create!(person_hash.merge({name: 'Peter', email: 'peter@example.com'}))
sarah = User.create!(person_hash.merge({name: 'Sarah', email: 'sarah@example.com'}))


# Event specification
event = Event.create!({name: 'Test event', manager_id: john.id})

# Times
day1 = 2.days.since
day2 = 5.days.since
hour14 = 14.hours
hour15 = 15.hours
hour18 = 18.hours
hour19 = 19.hours

time_slot_1 = TimeDetail.create!({event: event, from: (day1 + hour14), until: (day1 + hour15)})
time_slot_2 = TimeDetail.create!({event: event, from: (day2 + hour14), until: (day2 + hour15)})
time_slot_3 = TimeDetail.create!({event: event, from: (day2 + hour18), until: (day2 + hour19)})

# Activities
# TODO minimal person required
activity_beer = ActivityDetail.create!({event: event, name: 'Go to the pub', price: 100, price_per_unit: 'hour'})
activity_sport = ActivityDetail.create!({event: event, name: 'Play volleyball', price: 150, price_per_unit: 'hour'})

# Slots
time_slot_1_beer = Slot.create!({event: event, time_detail: time_slot_1, activity_detail: activity_beer})
time_slot_2_beer = Slot.create!({event: event, time_detail: time_slot_2, activity_detail: activity_beer})
time_slot_2_sport = Slot.create!({event: event, time_detail: time_slot_2, activity_detail: activity_sport})
time_slot_3_sport = Slot.create!({event: event, time_detail: time_slot_3, activity_detail: activity_sport})

# Participations
john_participant = Participant.create!({user: john, event: event})
jamie_participant = Participant.create!({user: jamie, event: event})
peter_participant = Participant.create!({user: peter, event: event})
sarah_participant = Participant.create!({user: sarah, event: event})

# Event definitions

#         | ------------------| ------------------- | ----------------- |
#         | time_slot_1       |  time_slot_2        | time_slot_3       |
#         | ----------------- | ------------------- | ----------------- |
#         | beer    |         | beer      | sport   | sport   |         |
#         | ------- | ------- | --------- | ------- | ------- | ------- |
# John    | n       |         | Y         | n       | n       |         |
# ----------------------------------------------------------------------
# Jamie   | n       |         | n         | Y       | n       |         |
# ----------------------------------------------------------------------
# Peter   | n       |         | Y         | Y       | n       |         |
# ----------------------------------------------------------------------
# Sarah   | n       |         | Y         | Y       | Y       |         |
#                              (should win)

[
    {user: john_participant, availabilities:  ['n', 'y', 'y', 'n']},
    {user: jamie_participant, availabilities: ['n', 'n', 'y', 'n']},
    {user: peter_participant, availabilities: ['n', 'y', 'y', 'n']},
    {user: sarah_participant, availabilities: ['n', 'y', 'y', 'y']}
].each do |entry|
    [time_slot_1_beer, time_slot_2_beer, time_slot_2_sport, time_slot_3_sport].each_with_index do |slot, index|
        availability_status = AvailabilityStatuses::AVAILABLE if entry[:availabilities][index] == 'y'
        availability_status = AvailabilityStatuses::NOT_AVAILABLE if entry[:availabilities][index] == 'n'

        unless availability_status.blank?
            Availability.create!({participant_id: entry[:user].id, slot_id: slot.id, status: availability_status})
        end
    end
end

# Conditions

# (Sarah || John) => Peter
# !Jamie -> Peter
# John && Sarah (organizers)
PreferenceCondition.create!({participant_id: peter_participant.id, condition_type: PreferenceTypes::OR_IMPLICATE, participants1: [sarah_participant, john_participant], participants2: [peter_participant]})
PreferenceCondition.create!({participant_id: peter_participant.id, condition_type: PreferenceTypes::NOT_AND_IMPLICATE, participants1: [jamie_participant], participants2: [peter_participant]})
PreferenceCondition.create!({participant_id: john_participant.id, condition_type: PreferenceTypes::AND, participants1: [john_participant], participants2: [sarah_participant]})

# (row to column) | WS - want to see, NS - nice to see, DC - dont care, NWS - want not to see
#
#         | John    | Jamie   | Peter   | Sarah   |
# -------------------------------------------------
# John    |         | WS      | DC      | WS      |
# -------------------------------------------------
# Jamie   | NS      |         | DC      | WS      |
# -------------------------------------------------
# Peter   | WS      | NWS     |         | WS      |
# -------------------------------------------------
# Sarah   | WS      | NS      | NS      |         |


# Prioritization
PreferencePrioritization.create!(participant_id: john_participant.id, for_participant_id: jamie_participant.id, multiplier: PreferencePrioritizationMultipliers::WANT_TO_SEE)
PreferencePrioritization.create!(participant_id: john_participant.id, for_participant_id: peter_participant.id, multiplier: PreferencePrioritizationMultipliers::DO_NOT_CARE)
PreferencePrioritization.create!(participant_id: john_participant.id, for_participant_id: sarah_participant.id, multiplier: PreferencePrioritizationMultipliers::WANT_TO_SEE)

PreferencePrioritization.create!(participant_id: jamie_participant.id, for_participant_id: john_participant.id, multiplier: PreferencePrioritizationMultipliers::NICE_TO_SEE)
PreferencePrioritization.create!(participant_id: jamie_participant.id, for_participant_id: peter_participant.id, multiplier: PreferencePrioritizationMultipliers::DO_NOT_CARE)
PreferencePrioritization.create!(participant_id: jamie_participant.id, for_participant_id: sarah_participant.id, multiplier: PreferencePrioritizationMultipliers::WANT_TO_SEE)

PreferencePrioritization.create!(participant_id: peter_participant.id, for_participant_id: john_participant.id, multiplier: PreferencePrioritizationMultipliers::WANT_TO_SEE)
PreferencePrioritization.create!(participant_id: peter_participant.id, for_participant_id: jamie_participant.id, multiplier: PreferencePrioritizationMultipliers::WANT_NOT_TO_SEE)
PreferencePrioritization.create!(participant_id: peter_participant.id, for_participant_id: sarah_participant.id, multiplier: PreferencePrioritizationMultipliers::WANT_TO_SEE)

PreferencePrioritization.create!(participant_id: sarah_participant.id, for_participant_id: john_participant.id, multiplier: PreferencePrioritizationMultipliers::WANT_TO_SEE)
PreferencePrioritization.create!(participant_id: sarah_participant.id, for_participant_id: jamie_participant.id, multiplier: PreferencePrioritizationMultipliers::NICE_TO_SEE)
PreferencePrioritization.create!(participant_id: sarah_participant.id, for_participant_id: peter_participant.id, multiplier: PreferencePrioritizationMultipliers::NICE_TO_SEE)