var app = angular.module('smartEventScheduler.dashboard', []);

app.config(function ($stateProvider) {
    $stateProvider.state('auth.dashboard', {
        templateUrl: 'templates/commons/dashboard.html',
        url: '/',
        controller: 'DashboardController'
    });
});

app.controller('DashboardController', function ($scope) {

});