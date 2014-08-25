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
    templateUrl: "/templates/index"

  $stateProvider.state 'related',
    url: "/:owner/:name/related"
    templateUrl: "/templates/index"

  $locationProvider.html5Mode(true)

App.config ($githubProvider) ->
