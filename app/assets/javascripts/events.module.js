var app = angular.module('smartEventScheduler.events', ['smartEventScheduler.common']);

app.config(function ($stateProvider) {
    $stateProvider.state('auth.myEvents', {
        templateUrl: 'templates/events/my.html',
        url: '/events/my',
        controller: 'MyEventsController'
    });

    $stateProvider.state('auth.newEvent', {
        templateUrl: 'templates/events/detail.html',
        url: '/new-event',
        controller: 'EventController'
    });

    $stateProvider.state('auth.eventDetail', {
        templateUrl: 'templates/events/detail.html',
        url: '/event/:id',
        controller: 'EventController'
    });

});

app.factory('EVENT_TIMES', function () {
    return {
        CURRENT: 'CURRENT',
        PAST: 'PAST'
    }
});

app.controller('MyEventsController', function ($scope, eventResourceService, flash, listLimitCount, EVENT_TIMES) {
    var Event = eventResourceService.getResource();

    $scope.events = [];
    $scope.limit = listLimitCount;
    $scope.limitCount = 1;
    $scope.timeOfEvents = EVENT_TIMES.CURRENT;
    $scope.EVENT_TIMES = EVENT_TIMES;

    $scope.loadList = function () {
        $scope.events = Event.getMyEvents({
            limit: $scope.limit,
            limitCount: $scope.limitCount,
            timeOfEvents: $scope.timeOfEvents
        }, function (data) {
            angular.forEach(data, function (event) {
                event.votingDeadline = new Date(event.votingDeadline);
            });
        });
    };

    $scope.removeEvent = function (event) {
        Event.delete(event, function (data) {
            var eventIndex = $scope.events.indexOf(event);

            $scope.events.splice(eventIndex, 1);
            flash.success = 'Successfully removed.'; // TODO animate deleted row
        });
    };

    $scope.setEventTimeFilter = function (eventsTime) {
        $scope.timeOfEvents = eventsTime;
        $scope.loadList();
    };
});

app.controller('EventController', function ($scope, $state, $stateParams, eventResourceService) {
    var Event = eventResourceService.getResource();

    if (angular.isDefined($stateParams.id)) {
        $scope.event = Event.get({id: $stateParams.id}, function (data) {
            angular.forEach(data.times, function (time) {
                time.from = new Date(time.from);
                time.until = new Date(time.until);
            })
        });
    } else {
        $scope.event = {
            votingDeadline: getCurrentDate().cloneAddSeconds(DAY_IN_SECONDS * 7),
            times: [],
            activities: [],
            slots: []
        };
    }

    $scope.existsItemWithoutId = function (collection) {
        var has = false;
        angular.forEach(collection, function (item) {
            if (angular.isUndefined(item.id)) {
                has = true;
            }
        });
        return has;
    };

    $scope.save = function () {
        Event.save($scope.event, function (data) {
            console.log('success event save callback');
            $state.go('auth.eventDetail', {id: data.id})
        });
    };
});

app.directive('eventActivityTimeSlot', function ($modal) {
    return {
        restrict: 'E',
        scope: {
            time: '=',
            activity: '=',
            selectedSlots: '='
        },
        templateUrl: 'templates/events/activity-time-slot.html',
        link: function (scope) {
            var notBlankString = function (text) {
                return angular.isDefined(text) && typeof text == 'string' && text.length > 0
            };

            var findTimeEntry = function (slots, timeId) {
                for (var i = 0; i < slots.length; i++) {
                    var slot = slots[i];
                    if (slot.timeDetailId == timeId) {
                        return slot;
                    }
                }

                return undefined;
            };

            var findActivityEntry = function (timeSlots, activityId) {
                for (var i = 0; i < timeSlots.length; i++) {
                    var slot = timeSlots[i];
                    if (slot.activityDetailId == activityId) {
                        return slot;
                    }
                }

                return undefined;
            };

            var findSlot = function (time, activity) {
                var slotWithTime = findTimeEntry(scope.selectedSlots, time.id);

                if (angular.isUndefined(slotWithTime)) {
                    return undefined;
                }

                return findActivityEntry(slotWithTime.activities, activity.id);
            };

            scope.slotToggleable = function () {
                return angular.isDefined(scope.time.id) && angular.isDefined(scope.activity.id)
            };

            scope.toggleSlot = function (time, activity) {
                if (angular.isUndefined(time.id) || angular.isUndefined(activity.id)) {
                    throw 'Error! Time or activity entity for this slot has not been persisted, yet!'
                }

                var slotWithTime = findTimeEntry(scope.selectedSlots, time.id);

                if (angular.isUndefined(slotWithTime)) {
                    scope.selectedSlots.push({
                        timeDetailId: time.id,
                        activities: []
                    });
                }

                var slotWithActivity = findActivityEntry(slotWithTime.activities, activity.id);

                if (angular.isDefined(slotWithActivity)) {
                    var slotIndex = slotWithTime.activities.indexOf(slotWithActivity)
                    slotWithTime.activities.splice(slotIndex, 1);
                } else {
                    slotWithTime.activities.push({
                        activityDetailId: activity.id,
                        note: ''
                    });
                }
            };

            scope.isSelected = function (time, activity) {
                return angular.isDefined(findSlot(time, activity));
            };

            scope.noteExists = function () {
                return scope.isSelected(scope.time, scope.activity) && notBlankString(scope.getSlot().note)
            };

            scope.getSlot = function () {
                return findSlot(scope.time, scope.activity);
            };

            scope.displaySlotModal = function () {
                $modal.open({
                    resolve: {
                        slot: function () {
                            return scope.getSlot();
                        }
                    },
                    templateUrl: 'templates/events/slot-modal.html',
                    controller: 'EventSlotModalController',
                    windowClass: 'modal-with-overlay'
                });
            };
        }
    }
});

app.controller('EventSlotModalController', function ($scope, $modalInstance, slot) {
    $scope.slot = slot;
});

app.factory('eventResourceService', function (apiVersion, restService) {
    return {
        getResource: function () {
            return restService.createRestResource('/' + apiVersion + '/events/:id.json', {id: '@id'},
                {
                    'getMyEvents': {method: 'GET', 'url': '/' + apiVersion + '/events/my.json', isArray: true},
                    'save': {method: 'POST', 'url': '/' + apiVersion + '/events.json'}
                }
            );
        }
    }
});
