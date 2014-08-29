#= require lodash
#= require spin.js
#= require angular
#= require angular-bootstrap
#= require angular-ui-router
#= require angular-ui-select
#= require angular-loading-bar
#= require angular-spinner
#= require_self
#= require_tree ./controllers
#= require_tree ./services

App = angular.module 'gsocial', [
  'angular-loading-bar'
  'ui.router'
  'ui.bootstrap'
  'ui.select'
  'angularSpinner'
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
    resolve:
      related: (Rails, $rootScope, $http, $stateParams, $state) ->
        query =
          name: "#{$stateParams.owner}/#{$stateParams.name}"
          popularity: 3
          excludeStarred: Rails.current_user?

        $rootScope.fetchRelated(query)

  $locationProvider.html5Mode(true)

App.run ($rootScope, $window, $http, $state, $stateParams, Rails, alert) ->
  $rootScope.githubLogin = ->
    $window.location.assign('/auth/github')

  $rootScope.githubLogout = ->
    $window.location.assign('/auth/logout')

  $rootScope.scrollTop = ->
    $window.scrollTo(0, 0)

  $rootScope.goToRelated = (model) ->
    $state.go('related', owner: model.owner.login, name: model.name)

  $rootScope.searchRepos = (query) ->
    url = "https://api.github.com/search/repositories?" +
          "q=#{query}&per_page=5&access_token=#{Rails.current_user.github_token}"

    $http.get(url, cache: true).then (response) ->
      response.data.items

  $rootScope.fetchRelated = (query) ->
    params =
      popularity: query.popularity

    if query.excludeStarred && Rails.current_user?
      params.user_id = Rails.current_user.id

    $http.get("/api/#{query.name}/related", params: params, cache: true).then (response) ->
      response.data

  $rootScope.$on '$stateChangeStart', ->
    $rootScope.loading = true

  $rootScope.$on '$stateChangeSuccess', ->
    $rootScope.loading = false

  $rootScope.$on '$stateChangeError',
  (event, toState, toParams, fromState, fromParams, error) ->
    $rootScope.loading = false
    alert.danger(message: error.statusText)

App.constant('Rails', window.Rails)

App.run ($rootScope, Rails) ->
  $rootScope.Rails = Rails
  $rootScope.alert = (message) ->
    alert(message)
