var app = angular.module('smartEventScheduler.common', ['smartEventScheduler.common.rest']);

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
               '<span class="validation-error" ng-if="'+attrs.form+'.'+attrs.name+'.$error.min">Value must be equal or greater than ' +attrs.min+ '.</span>' +
               '<span class="validation-error" ng-if="'+attrs.form+'.'+attrs.name+'.$error.max">Value must be equal or less than ' +attrs.max+ '.</span>' +
               '<span class="validation-error" ng-if="'+attrs.form+'.'+attrs.name+'.$error.minlength">Field must be at least ' +attrs.minlength+ ' chars long.</span>' +
               '<span class="validation-error" ng-if="'+attrs.form+'.'+attrs.name+'.$error.maxlength">Field must be maximal ' +attrs.minlength+ ' chars long.</span>' +
               '<span class="validation-error" ng-if="'+attrs.form+'.'+attrs.name+'.$error.required">This field is required!</span>' +
               '<span class="validation-error" ng-if="'+attrs.form+'.'+attrs.name+'.$error.numeric">This field must be number!</span>';

           var compiled = $compile(validationHTML)(scope);
           element.after( angular.element( compiled ));
       }
   }
});