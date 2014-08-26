#= require lodash
#= require github
#= require angular
#= require angular-bootstrap
#= require angular-ui-router
#= require angular-ui-select
#= require angular-github-adapter/src/github
#= require angular-github-adapter/src/githubRepository
#= require angular-github-adapter/src/githubUser
#= require angular-github-adapter/src/githubGist
#= require_self
#= require_tree ./controllers

App = angular.module 'gsocial', [
  'ui.router'
  'ui.bootstrap'
  'ui.select'
  'pascalprecht.github-adapter'
]

App.config ($stateProvider, $locationProvider) ->
  $stateProvider.state 'index',
    url: "/"
    controller: 'SearchCtrl'
    templateUrl: "/templates/index"

  $stateProvider.state 'related',
    url: "/:owner/:name/related"
    controller: 'SearchCtrl'
    templateUrl: "/templates/index"

  $locationProvider.html5Mode(true)

App.run ($rootScope, $window, $http) ->
  $rootScope.githubLogin = ->
    $window.location.assign('/auth/github')

  $rootScope.githubLogout = ->
    $window.location.assign('/auth/logout')

  $rootScope.scrollTop = ->
    $window.scrollTo(0, 0)


App.constant('Rails', window.Rails)

App.config ($githubProvider, Rails) ->
  if Rails.current_user
    $githubProvider.token(Rails.current_user.github_token)
    $githubProvider.authType('basic')

App.run ($rootScope, Rails) ->
  $rootScope.Rails = Rails
  $rootScope.alert = (message) ->
    alert(message)
