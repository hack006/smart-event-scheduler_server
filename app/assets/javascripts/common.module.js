var app = angular.module('smartEventScheduler.common', ['ngAnimate', 'smartEventScheduler.common.rest']);

/* common directives and services put HERE */
app.value('apiVersion', 'api1');

app.factory('authenticationService', function () {
    return {
        getLoggedUser: function () {
            return {id: 1}; // @TODO
        }
    }
});

app.directive('displayValidations', function ($compile) {
    return {
        restrict: 'A',
        scope: true,
        link: function (scope, element, attrs) {
            var validationHTML =
                '<span class="validation-error" ng-if="' + attrs.form + '.' + attrs.name + '.$error.min">Value must be equal or greater than ' + attrs.min + '.</span>' +
                '<span class="validation-error" ng-if="' + attrs.form + '.' + attrs.name + '.$error.max">Value must be equal or less than ' + attrs.max + '.</span>' +
                '<span class="validation-error" ng-if="' + attrs.form + '.' + attrs.name + '.$error.minlength">Field must be at least ' + attrs.minlength + ' chars long.</span>' +
                '<span class="validation-error" ng-if="' + attrs.form + '.' + attrs.name + '.$error.maxlength">Field must be maximal ' + attrs.minlength + ' chars long.</span>' +
                '<span class="validation-error" ng-if="' + attrs.form + '.' + attrs.name + '.$error.required">This field is required!</span>' +
                '<span class="validation-error" ng-if="' + attrs.form + '.' + attrs.name + '.$error.numeric">This field must be number!</span>';

            var compiled = $compile(validationHTML)(scope);
            element.after(angular.element(compiled));
        }
    }
});

app.directive('loadMoreButton', function () {
    return {
        restrict: 'E',
        scope: {
            loadingFunction: '&',
            limit: '=',
            limitCount: '='
        },
        template: '<a class="btn btn-primary" ng-click="loadMore()">Load more</a>',
        link: function (scope, element, attrs) {
            scope.loadMore = function () {
                scope.limitCount = scope.limitCount + 1;
                scope.loadingFunction()(scope.limit, scope.limitCount);
            };

            scope.loadMore();
        }
    }
});

app.value('listLimitCount', 20);

app.filter('remainingTime', function () { // TODO rewrite to better orientation estimations
    return function (date) {
        if (angular.isUndefined(date) || !angular.isDate(date)) {
            return '';
        }

        var dateDifferenceInMillis = date.getTime() - (new Date()).getTime();
        if (dateDifferenceInMillis < 0) {
            return 'in the past';
        }

        var daySingularPlural = function (timeInterval) {
            return (timeInterval.getDays() > 1) ? 'days' : 'day'
        };

        var hourSingularPlural = function (timeInterval) {
            return (timeInterval.getHours() > 1) ? 'hours' : 'hour'
        };

        var minuteSingularPlural = function (timeInterval) {
            return (timeInterval.getMinutes() > 1) ? 'minutes' : 'minute'
        };

        var timeFromNow = new TimeInterval(dateDifferenceInMillis);
        if (timeFromNow.getYears() > 0) {
            return 'more than year';
        } else if (timeFromNow.getMonths() > 3) {
            return 'about ' + timeFromNow.getMonths() + ' months';
        } else if (timeFromNow.getMonths() > 0) {
            var days = timeFromNow.getMonths() * 30 + timeFromNow.getDays();
            return 'about ' + days + ' ' + ((days > 1) ? ' days' : 'day');
        } else if (timeFromNow.getDays() > 0) {
            return 'about ' + timeFromNow.getDays() + ' ' + daySingularPlural(timeFromNow) + ' ' + timeFromNow.getHours() + ' ' + hourSingularPlural(timeFromNow);
        } else {
            return 'about ' + timeFromNow.getHours() + ' ' + hourSingularPlural(timeFromNow) + ' ' + timeFromNow.getMinutes() + ' ' + minuteSingularPlural(timeFromNow);
        }
    }
});