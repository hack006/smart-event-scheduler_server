var app = angular.module('smartEventScheduler.events', ['ui.router']);

app.config(function ($stateProvider) {
    $stateProvider.state('myEvents', {
        templateUrl: 'templates/events/my.html',
        url: '/events/my',
        controller: 'MyEventsController'
    });

    $stateProvider.state('eventDetail', {
        templateUrl: 'templates/events/detail.html',
        url: '/events/:id',
        controller: 'EventController'
    });
});

app.controller('MyEventsController', function ($scope, eventResourceService) {
    var Event = eventResourceService.getResource();

    $scope.events = Event.getMyEvents();

    $scope.removeEvent = function (event) {
        // TODO
    }
});

app.controller('EventController', function ($scope, $stateParams, eventResourceService) {
    var Event = eventResourceService.getResource();

    $scope.event = Event.get({id: $stateParams.id});
});

app.factory('eventResourceService', function (apiVersion, $resource) {
    return {
        getResource: function () {
            return $resource('/'+apiVersion+'/events/:id.json', {id: '@id'},
                {
                    'getMyEvents': {method: 'GET', 'url': '/'+apiVersion+'/events/my.json', isArray: true}
                });
        }
    }
});
