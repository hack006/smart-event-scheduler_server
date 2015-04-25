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
            slots: {} // {<time_detail_id>: [<activity_ids>]}
        };
    }

    $scope.defaultTimeSlotInMinutes = 60;

    $scope.addTime = function () {
        $scope.event.times.push({
            from: getCurrentDate(),
            until: getCurrentDate()
        });
    };

    $scope.removeTime = function (time) {
        var eventIndex = $scope.event.times.indexOf(time);
        $scope.event.times.splice(eventIndex, 1);
    };

    $scope.addActivity = function () {
        $scope.event.activities.push({});
    };

    $scope.removeActivity = function (activity) {
        var eventIndex = $scope.event.activities.indexOf(activity);
        $scope.event.activities.splice(eventIndex, 1);
    };

    $scope.toggleSlot = function (time, activity) {
        var slots = $scope.event.slots;
        if (angular.isUndefined(slots[time.id])) {
            slots[time.id] = [];
        }
        var indexOfActivity = slots[time.id].indexOf(activity.id);
        if (indexOfActivity == -1) {
            slots[time.id].push(activity.id);
        } else {
            slots.splice(indexOfActivity, 1);
        }
    };

    $scope.isSelected = function (time, activity) {
        var slots = $scope.event.slots;
        if (angular.isUndefined(slots[time.id])) {
            return false;
        } else {
            return slots[time.id].contains(activity.id);
        }
    };

    $scope.save = function () {
        Event.save($scope.event, function (data) {
            console.log('success event save callback');
            $state.go('auth.eventDetail', {id: data.id})
        });
    };
});

app.controller('EventTimeController', function ($scope) {
    // fill until with the from + default slot length value

    var dateToMinutes = function (date) {
        return date.getTime() / 60000;
    };

    $scope.$watch('time.from.getTime()', function () {
        if (angular.isDefined($scope.time.from) && $scope.timeForm.until.$pristine) {
            $scope.time.until = $scope.time.from.cloneAddSeconds(60 * $scope.defaultTimeSlotInMinutes);
        }
    });

    $scope.dateDifferenceInMinutes = function (date1, date2) {
        if (angular.isUndefined(date1) || angular.isUndefined(date2)) {
            return 0
        } else {
            return dateToMinutes(new Date(date1.getTime() - date2.getTime()))
        }
    };
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
