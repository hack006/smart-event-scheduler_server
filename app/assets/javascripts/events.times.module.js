var app = angular.module('smartEventScheduler.events.times', ['ui.router']);

app.config(function ($stateProvider) {
    $stateProvider.state('auth.eventTimes', {
        templateUrl: 'templates/events/times.html',
        url: '/event/:event_id/times',
        controller: 'EventTimesController'
    });
});

app.controller('EventTimes', function ($scope) {

});


app.factory('eventTimeResourceService', function (apiVersion, $resource) {
    return {
        getResource: function () {
            return $resource('/'+apiVersion+'/events/:id.json', {id: '@id'},
                {
                    'getMyEvents': {method: 'GET', 'url': '/'+apiVersion+'/events/my.json', isArray: true}
                });
        }
    }
});
