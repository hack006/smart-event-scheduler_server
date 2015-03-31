app = angular.module('smartEventSchedulerApp',
    [
        // angular & support libraries
        'ngResource',
        'ui.bootstrap',
        'ui.router',
        'ui.bootstrap.datetimepicker',
        'angular-flash.service',
        'angular-flash.flash-alert-directive',

        // application modules
        'smartEventScheduler.common',
        'smartEventScheduler.dashboard',
        'smartEventScheduler.events'
    ]);

app.config(function ($stateProvider, $urlRouterProvider, flashProvider) {
    $urlRouterProvider.otherwise('/');

    $stateProvider.state('auth', {
       templateUrl: 'templates/layouts/authenticated.html'
    });

    // Support bootstrap 3.0 "alert-danger" class with error flash types
    flashProvider.errorClassnames.push('alert-danger');
});

app.run(function ($rootScope) {
    //$rootScope.isObjectEmpty = isObjectEmpty;
});
