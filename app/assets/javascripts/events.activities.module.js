var app = angular.module('smartEventScheduler.events.activities', ['smartEventScheduler.common']);

app.directive('eventActivities', function (defaultValues) {
   return {
       restrict: 'E',
       scope: {
           activities: '='
       },
       templateUrl: 'templates/activities/event-activities',
       link: function (scope) {
           scope.defaultPrice = defaultValues.price;
           scope.defaultCurrency = defaultValues.currency;
           scope.defaultActivityDurationUnit = defaultValues.activityDurationUnit;

           scope.addActivity = function () {
               scope.activities.push({
                   price: scope.defaultPrice,
                   priceUnit: scope.defaultCurrency,
                   pricePerUnit: scope.defaultActivityDurationUnit
               });
           };

           scope.removeActivity = function (activity) {
               var eventIndex = scope.activities.indexOf(activity);
               scope.activities.splice(eventIndex, 1);
           };
       }
   }
});