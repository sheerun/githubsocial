App = angular.module('gsocial')

App.controller 'SearchCtrl', (Rails, $scope, $github, $http, $stateParams, $state) ->
  $scope.enter = false

  $scope.search =
    query: ''
    results: []

  $scope.related =
    results: []
    subject: null
    excludeStarred: true

  $scope.searchRepos = (query) ->
    $http.get("https://api.github.com/search/repositories?q=#{query}&per_page=5&access_token=#{Rails.current_user.github_token}", cache: true).then (response) ->
      $scope.search.results = response.data.items
      $scope.search.results

  $scope.goToRelated = (model) ->
    $state.go('related', owner: model.owner.login, name: model.name)

  $scope.fetchRelated = ->
    params = {}

    if $scope.related.excludeStarred
      params.user_id = Rails.current_user.id

    $scope.repoName = "#{$stateParams.owner}/#{$stateParams.name}"
    $http.get("/api/#{$scope.repoName}/related", params: params, cache: true).then (response) ->
      $scope.related.subject = response.data.subject
      $scope.related.results = response.data.related

  if $stateParams.owner && $stateParams.name
    $scope.fetchRelated()