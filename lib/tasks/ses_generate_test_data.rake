namespace :ses do
  AVAILABLE_PROBABILITY = 0.7
  PRIORIZATION_PROBABILITY = {want_to_see: 0.25,   nice_to_see: 0.2, do_not_care: 0.4, want_not_to_see: 0.15}

  task :generate_test_data, [:participant_count, :times_count] => :environment do |t, args|
    raise 'Error, can be only run under TEST environment' if Rails.env != 'test'
    Rake::Task['db:drop'].invoke
    Rake::Task['db:drop'].reenable
    Rake::Task['db:create'].invoke
    Rake::Task['db:create'].reenable
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:migrate'].reenable

    participant_count = args[:participant_count].to_i
    participant_half_count = (participant_count / 2).ceil
    times_count = args[:times_count].to_i
    activities_count = (times_count / 2).ceil

    puts "\
    Generating data ... \n\
    --------setup-------\n\
    #participants: #{participant_count}\n\
    #times: #{times_count}\n\
    #activities: #{activities_count}\n\
    --------------------\n"




    # Generate users
    users = Array.new(participant_count)

    person_hash = {password: '12345678', password_confirmation: '12345678'}
    for i in 0..(participant_count-1)
      user = User.create!(person_hash.merge({name: "User#{i}", email: "user#{i}@example.com"}))
      users[i] = user
    end

    # create event
    event = Event.create!({name: 'Test event', manager_id: users.first.id})

    # Create event participants
    participants = Array.new(participant_count)

    users.each_with_index do |user, index|
      participants[index] = Participant.create!({user: user, event: event})
    end

    # Activities
    activities = Array.new(activities_count)
    for i in 0..(activities_count-1)
      lb = [2, rand(participant_half_count)].max
      ub = participant_half_count + rand(participant_count - participant_half_count)

      activities[i] = ActivityDetail.new({event: event, name: "Activity#{i}", price: 100, price_per_unit: 'hour'})

      case rand(4)
        when 1
          activities[i].minimum_count = lb
        when 2
          activities[i].maximum_count = ub
        when 3
          activities[i].minimum_count = lb
          activities[i].maximum_count = ub
      end

      activities[i].save!
    end

    # Times
    times = Array.new(times_count)
    for i in 0..(times_count-1)
      times[i] = TimeDetail.create!({event: event, from: 3.hours, until: 4.hours})
    end

    # Slots
    slots = []

    activities.each_with_index do |activity, activity_index|
      times.each_with_index do |time, time_index|
        slots << Slot.create!({event: event, time_detail: time, activity_detail: activity})
      end
    end

    # Availability
    slots.each do |slot|
      participants.each do |participant|
        participant_slot_availability = Availability.new({participant_id: participant.id, slot_id: slot.id})

        if rand() < AVAILABLE_PROBABILITY
          participant_slot_availability.status = AvailabilityStatuses::AVAILABLE
        else
          participant_slot_availability.status = AvailabilityStatuses::NOT_AVAILABLE
        end

        participant_slot_availability.save!
      end
    end

    # Priorization
    participants.each_with_index do |participant, participant_index|
      participants.each_with_index do |prioritized_participant, prioritized_participant_index|
        want_to_see_interval = 0..PRIORIZATION_PROBABILITY[:want_to_see]
        nice_to_see_interval = want_to_see_interval.last..(want_to_see_interval.last + PRIORIZATION_PROBABILITY[:nice_to_see])
        do_not_care_interval = nice_to_see_interval.last..(nice_to_see_interval.last + PRIORIZATION_PROBABILITY[:do_not_care])
        want_not_to_see_interval = do_not_care_interval.last..1

        priority = PreferencePrioritization.new(participant_id: participant.id, for_participant_id: prioritized_participant.id)

        case rand
          when want_to_see_interval
            priority.multiplier = PreferencePrioritizationMultipliers::WANT_TO_SEE
          when nice_to_see_interval
            priority.multiplier = PreferencePrioritizationMultipliers::NICE_TO_SEE
          when do_not_care_interval
            priority.multiplier = PreferencePrioritizationMultipliers::DO_NOT_CARE
          when want_not_to_see_interval
            priority.multiplier = PreferencePrioritizationMultipliers::WANT_NOT_TO_SEE
        end

        priority.save!
      end
    end

    # Conditions
    #
    # only conditions: (<>[&&<>]*) => <>, (<>[||<>]*) => <>, (!<>[&&!<>]*) => <>
    # Array<Integer> => Integer: M => n
    #   M := {1..participant_half_count}
    #
    # number of conditions per user := {0..3}
    participants.each_with_index do |participant, participant_index|
      conditions = [PreferenceTypes::AND_IMPLICATE, PreferenceTypes::OR_IMPLICATE, PreferenceTypes::AND_IMPLICATE, PreferenceTypes::OR_IMPLICATE,PreferenceTypes::AND_IMPLICATE, PreferenceTypes::OR_IMPLICATE, PreferenceTypes::NOT_AND_IMPLICATE]

      conditions.shuffle.take(1+rand(3)).each do |condition|
        condition_participant_list_count = [1, rand(participant_half_count)].max
        participants1_list = participants.shuffle.take(condition_participant_list_count)

        PreferenceCondition.create!({participant_id: participant.id, condition_type: condition, participants1: participants1_list, participants2: [participant]})
      end

    end

  end
end