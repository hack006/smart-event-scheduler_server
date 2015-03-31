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

app.controller('MyEventsController', function ($scope, eventResourceService, flash) {
    var Event = eventResourceService.getResource();

    $scope.events = Event.getMyEvents();

    $scope.removeEvent = function (event) {
        var Event = eventResourceService.getResource();

        Event.delete(event, function (data) {
            var eventIndex = $scope.events.indexOf(event);

            $scope.events.splice(eventIndex, 1);
            flash.success = 'Successfully removed.'
        });
    }
});

app.controller('EventController', function ($scope, $state, $stateParams, eventResourceService) {
    var Event = eventResourceService.getResource();

    if (angular.isDefined($stateParams.id)) {
        $scope.event = Event.get({id: $stateParams.id});
    } else {
        $scope.event = {
            times: [],
            activities: []
        };
    }

    $scope.addTime = function () {
        $scope.event.times.push({});
    };

    $scope.addActivity = function () {
        $scope.event.activities.push({});
    };


    $scope.save = function () {
        Event.save($scope.event, function (data) {
            console.log('success event save callback');
            $state.go('auth.eventDetail', { id: data.id })
        });
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
