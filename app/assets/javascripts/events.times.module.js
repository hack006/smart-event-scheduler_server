var app = angular.module('smartEventScheduler.events.times', ['ui.router', 'smartEventScheduler.common']);

app.config(function ($stateProvider) {
    $stateProvider.state('auth.eventTimes', {
        templateUrl: 'templates/events/times.html',
        url: '/event/:event_id/times',
        controller: 'EventTimesController'
    });
});

app.controller('EventTimes', function ($scope) {

});

app.controller('EventTimeController', function ($scope) {
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

app.directive('eventTimes', function (defaultValues) {
   return {
       restrict: 'E',
       scope: {
           times: '='
       },
       templateUrl: 'templates/times/event-times.html',
       link: function (scope) {
           scope.defaultTimeSlotInMinutes = defaultValues.defaultTimeSlotInMinutes;

           scope.addTime = function () {
               scope.times.push({
                   from: getCurrentDate(),
                   until: getCurrentDate()
               });
           };

           scope.removeTime = function (time) {
               var eventIndex = scope.times.indexOf(time);
               scope.times.splice(eventIndex, 1);
           };
       }
   }
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
