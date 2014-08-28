App = angular.module('gsocial')

App.controller 'IndexCtrl', ->


App.controller 'SearchCtrl', (Rails, $scope, $github, $http, $stateParams, $state) ->
  $scope.search =
    query: ''
    results: []

  $scope.related =
    enabled: false
    results: []
    subject: null
    excludeStarred: Rails.current_user?

  $scope.searchRepos = (query) ->
    url = "https://api.github.com/search/repositories?" +
          "q=#{query}&per_page=5&access_token=#{Rails.current_user.github_token}"

    $http.get(url, cache: true).then (response) ->
      $scope.search.results = response.data.items
      $scope.search.results

  $scope.fetchRelated = ->
    params = {}

    if $scope.related.excludeStarred && Rails.current_user?
      params.user_id = Rails.current_user.id

    $scope.repoName = "#{$stateParams.owner}/#{$stateParams.name}"
    $http.get("/api/#{$scope.repoName}/related", params: params, cache: true).then (response) ->
      $scope.related.subject = response.data.subject
      $scope.related.results = response.data.related

  if $stateParams.owner && $stateParams.name
    $scope.related.enabled = true
    $scope.fetchRelated()
