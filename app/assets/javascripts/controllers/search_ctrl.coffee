App = angular.module('gsocial')

App.controller 'IndexCtrl', ->


App.controller 'SearchCtrl', (Rails, $scope, $rootScope, $stateParams, $state, related) ->

  $scope.related = related

  $scope.query =
    name: "#{$stateParams.owner}/#{$stateParams.name}"
    popularity: 3
    excludeStarred: Rails.current_user?

  $scope.fetchRelated = ->
    $rootScope.fetchRelated($scope.query).then (related) ->
      $scope.related = related
