app = angular.module('smartEventSchedulerApp',
    [
        // angular & support libraries
        'ngResource',
        'ui.bootstrap',
        'ui.router',
        'ui.bootstrap.datetimepicker',

        // application modules
        'smartEventScheduler.common',
        'smartEventScheduler.events'
    ]);

app.config(function ($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise('/');
});

app.run(function ($rootScope) {
    //$rootScope.isObjectEmpty = isObjectEmpty;
});
