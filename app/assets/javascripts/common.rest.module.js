/**
 * Created by hack006 on 30.3.15.
 */
var app = angular.module('smartEventScheduler.common.rest', ['ngResource']);

app.factory('restService', function ($resource, restProcessingRequestCount, flash) {
    return {
        createRestResource: function (url, defaultParams, actions) {
            var restResource = $resource(url, defaultParams, actions);

            var extendedRestService = {};
            var supportedActions = [];
            angular.forEach(actions, function (action, actionName) {
                supportedActions.push(actionName);
            });
            var includedActions = ['get', 'save', 'query', 'remove', 'delete'];
            angular.forEach(includedActions, function (actionName) {
                supportedActions.push(actionName);
            });

            angular.forEach(supportedActions, function (actionName) {
                extendedRestService[actionName] = function (parameters, success, error) {

                    console.log('processing: ' + parameters);
                    restProcessingRequestCount += 1;

                    return restResource[actionName].call(restResource, parameters,
                        function (data, responseHeaders) { // success
                            restProcessingRequestCount -= 1;
                            if (angular.isFunction(success)) {
                                success(data, responseHeaders);
                            }
                            flash.success = 'Processed correctly.'; // TODO remove in production ?
                        },
                        function (httpResponse) { // error
                            console.log('Error processing request.');
                            restProcessingRequestCount -= 1;
                            if (angular.isFunction(error)) {
                                error(httpResponse);
                            }
                            flash.error = 'We apologize, something went wrong. Your action was not processed correctly. Please repeat it.'
                        });
                };
            });

            return extendedRestService;
        }
    }
});

app.directive('restLoader', function (restProcessingRequestCount) {
   return {
       templateUrl: 'templates/commons-rest/rest-loader.html',
       scope: true,
       link: function (scope, element, attrs) {
            scope.displayLoader = function () {
                return restProcessingRequestCount > 0
            }
       }
   }
});

app.value('restLoaderElementID', 'restLoader');

app.value('restProcessingRequestCount', 0);