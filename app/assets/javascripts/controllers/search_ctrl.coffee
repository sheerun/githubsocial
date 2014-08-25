App = angular.module('gsocial')

App.controller 'SearchCtrl', ($scope, $github, $http, $stateParams) ->
  $scope.search =
    query: ''
    results: []

  $scope.searchRepos = _.debounce ->

    query = $scope.search.query

    $http.get("https://api.github.com/search/repositories?q=#{query}&per_page=10", cache: true).then (response) ->
      $scope.search.results = response.data.items

  , 500

  if $stateParams.owner && $stateParams.name
    $scope.repoName = "#{$stateParams.owner}/#{$stateParams.name}"
    $http.get("/api/#{$scope.repoName}/related", cache: true).then (response) ->
      $scope.search.results = response.data
