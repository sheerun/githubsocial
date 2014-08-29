#= require lodash
#= require github
#= require angular
#= require angular-bootstrap
#= require angular-ui-router
#= require angular-ui-select
#= require_self
#= require_tree ./controllers

App = angular.module 'gsocial', [
  'ui.router'
  'ui.bootstrap'
  'ui.select'
]

App.config ($stateProvider, $locationProvider) ->
  $stateProvider.state 'index',
    url: "/"
    controller: 'IndexCtrl'
    templateUrl: "/templates/index"

  $stateProvider.state 'related',
    url: "/:owner/:name"
    controller: 'SearchCtrl'
    templateUrl: "/templates/related"

  $locationProvider.html5Mode(true)

App.run ($rootScope, $window, $http, $state, Rails) ->
  $rootScope.githubLogin = ->
    $window.location.assign('/auth/github')

  $rootScope.githubLogout = ->
    $window.location.assign('/auth/logout')

  $rootScope.scrollTop = ->
    $window.scrollTo(0, 0)

  $rootScope.goToRelated = (model) ->
    $state.go('related', owner: model.owner.login, name: model.name)

  $rootScope.search =
    query: ''
    results: []

  $rootScope.searchRepos = (query) ->
    url = "https://api.github.com/search/repositories?" +
          "q=#{query}&per_page=5&access_token=#{Rails.current_user.github_token}"

    $http.get(url, cache: true).then (response) ->
      $rootScope.search.results = response.data.items
      $rootScope.search.results


App.constant('Rails', window.Rails)

App.run ($rootScope, Rails) ->
  $rootScope.Rails = Rails
  $rootScope.alert = (message) ->
    alert(message)
