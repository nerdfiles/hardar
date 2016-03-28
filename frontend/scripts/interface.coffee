define([
  'angularAMD',
  "angular-route",
  "angular-animate",
  "angular-aria",
  "angular-messages",
  "angular-cookies",
  "angular-resource",
  "angular-sanitize",
  "angular-storage",
  "angular-material",
  "angular-waypoints"
], (angularAMD) ->

  app = angular.module('hardar', [
    'ngRoute',
    "ngAnimate",
    "ngCookies",
    "ngResource",
    "ngSanitize",
    'ngAria',
    'ngMessages',
    'ngStorage',
    'ngMaterial',
    'zumba.angular-waypoints'
  ])

  .constant('SECURED_ROUTES', {})
  .constant('loginRedirectPath', '/pages/login')

  .config(['$routeProvider', 'SECURED_ROUTES', ($routeProvider, SECURED_ROUTES) ->
    $routeProvider.whenAuthenticated = (path, route) ->
      route.resolve = route.resolve || {}
      route.resolve.user = ['Auth', (Auth) ->
        Auth.$requireAuth()
      ]
      $routeProvider.when(path, route)
      SECURED_ROUTES[path] = true
      $routeProvider
  ])

  .factory('Auth', [() ->
    authenticationInterface.user = false
    {
      $requireAuth: () ->
        authenticationInterface.user = true
      $onAuth: (callback) ->
        callback(authenticationInterface.user)
    }
  ])

  .config(['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
    $locationProvider.html5Mode true

    $routeProvider
      .when("/:section?", angularAMD.route(
        templateUrl   : 'views/page.base.html'
        controllerUrl : 'modules/home'
      ))

      .when('/pages/login', angularAMD.route(
        templateUrl   : 'views/page.login.html'
        controllerUrl : 'modules/login'
      ))

      .whenAuthenticated('/pages/account', angularAMD.route(
        templateUrl   : 'views/page.account.html'
        controllerUrl : 'modules/account'
      ))

      .otherwise(redirectTo: '/')
  ])

  .run([
    '$rootScope',
    '$location',
    'Auth',
    'SECURED_ROUTES',
    'loginRedirectPath',
    '$anchorScroll',
  ], ($rootScope, $location, Auth, SECURED_ROUTES, loginRedirectPath, $anchorScroll) ->

      $rootScope.showMenu = true
      $rootScope.toggleMenu = () ->
        $rootScope.showMenu = !$rootScope.showMenu

      $rootScope.scrollTo = (id) ->
        if $location.$$path != '/'
          $location.path(id)
        old = $location.hash()
        $location.hash(id)
        $anchorScroll()
        $location.hash(old)

      Auth.$onAuth(check)
      $rootScope.$on('$routeChangeError', (e, next, prev, error) ->
        if error == 'AUTH_REQUIRED'
          $location.path loginRedirectPath 
      )

      check = (user) ->
        if !user and authRequired $location.path()
          $location.path(loginRedirectPath)

      authRequired = (path) ->
        return SECURED_ROUTES.hasOwnProperty path
  )

  angularAMD.bootstrap(app)
)
