App = angular.module('gsocial')

App.service 'alert', ($rootScope) ->
  $rootScope.alerts = []

  $rootScope.$on '$locationChangeSuccess', ->
    alertService.closeAll()

  alertService =
    add: (alert) ->
      alert = angular.extend(close: (-> alertService.close(this)), alert)
      $rootScope.alerts = [alert]
      $rootScope.scrollTop()
      alert

    success: (alert) ->
      this.add(angular.extend(alert, type: 'success'))

    info: (alert) ->
      this.add(angular.extend(alert, type: 'info'))

    warning: (alert) ->
      this.add(angular.extend(alert, type: 'warning'))

    danger: (alert) ->
      this.add(angular.extend(alert, type: 'danger'))

    closeAll: ->
      $rootScope.alerts = []

    close: (alert) ->
      index = $rootScope.alerts.indexOf(alert)
      this.closeIdx(index) if index != -1

    closeIdx: (index) ->
      $rootScope.alerts.splice(index, 1)
