App = angular.module('gsocial')

App.controller 'SearchCtrl', (Rails, $scope, $github, $http, $stateParams) ->
  $scope.search =
    query: ''
    results: []

  $scope.related =
    results: []
    subject: null

  $scope.searchRepos = _.debounce ->

    query = $scope.search.query

    $http.get("https://api.github.com/search/repositories?q=#{query}&per_page=5&access_token=#{Rails.current_user.github_token}", cache: true).then (response) ->
      $scope.search.results = response.data.items

  , 500

  if $stateParams.owner && $stateParams.name
    $scope.repoName = "#{$stateParams.owner}/#{$stateParams.name}"
    $http.get("/api/#{$scope.repoName}/related", cache: true).then (response) ->
      $scope.related.subject = response.data.shift()
      $scope.related.results = response.data
      $scope.search.results = []
