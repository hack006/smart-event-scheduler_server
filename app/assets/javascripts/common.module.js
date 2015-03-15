var app = angular.module('smartEventScheduler.common', []);

/* common directives and services put HERE */
app.value('apiVersion', 'api1');

app.factory('authenticationService', function () {
   return {
       getLoggedUser: function () {
           return {id: 1}; // @TODO
       }
   }
});