App = angular.module('gsocial')

App.controller 'IndexCtrl', ->


App.controller 'SearchCtrl', (Rails, $scope, $http, $stateParams, $state) ->

  $scope.related =
    enabled: false
    results: []
    subject: null
    popularity: 5
    excludeStarred: Rails.current_user?

  $scope.fetchRelated = ->
    params = { popularity: $scope.related.popularity }

    if $scope.related.excludeStarred && Rails.current_user?
      params.user_id = Rails.current_user.id

    $scope.repoName = "#{$stateParams.owner}/#{$stateParams.name}"
    $http.get("/api/#{$scope.repoName}/related", params: params, cache: true).then (response) ->
      $scope.related.subject = response.data.subject
      $scope.related.results = response.data.related

  if $stateParams.owner && $stateParams.name
    $scope.related.enabled = true
    $scope.fetchRelated()
