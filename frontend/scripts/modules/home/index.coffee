###
@ngdoc home
@name hardar.modules.controllers
###

define(['interface', 'angular'], (__interface__, angular) ->

    ###
    @ngdoc controller
    @name hardar.modules.controllers:HomeController
    @requires $scope
    @description
    Controller for page.base.html template.
    ###

    HomeController = ($scope, $http) ->

        CONTENT_CHANNEL = '/content'
        ethHost = 'localhost'
        ethPort = 8545
        config = null


        refreshProperties = (newRoot) ->

            ###
            @name refreshProperties
            @inner
            ###

            path = 'properties/'
            if newRoot
                path = '/ipfs/' + newRoot + '/' + path

            $http.jsonp path + 'index.json', (properties, status, xhr) ->
                properties.map (property, index) ->
                    $scope.properties.push(buildProperty( path, property, index ))


        buildProperty = ( path, property, index ) ->

            ###
            @name buildProperty
            @inner
            ###

            propertyConstruct =
              index : index
              id    : property

            getContent path + property + '/title', ( err, title ) ->
                propertyConstruct.title = title

            getContent path + property + '/content', ( err, content ) ->
                isHttp = /^https?:\/\//
                if isHttp.test( content )
                    propertyConstruct.hrefContent = content
                else
                    propertyConstruct.hrefContent = '/ipfs/' + property

            getContent path + property + '/index.json', ( err, comments ) ->
                propertyConstruct.commentCount = comments.length
                propertyConstruct.hrefProperty = property


        getContent = (url, cb) ->

            ###
            @name getContent
            @inner
            ###

            $http.get url, (responseText, status, xhr) ->
                cb( !responseText, responseText )


        $http.get 'config', (responseText) ->

            try
                config = JSON.parse( responseText )
                if config.defaults
                    ethHost = config.defaults.eth_host
                    ethPort = config.defaults.eth_port
                    CONTENT_CHANNEL = config.defaults.shh_channel
                    $scope.ipfsStatus =
                      "connected": true
            catch error
                console.log( "Unable to parse config" )

            web3.setProvider( new web3.providers.HttpProvider( "http://" + ethHost + ":" + ethPort ) )
            try
                $scope.identity = web3.shh.newIdentity()
                messageFilter = web3.shh.filter({
                  topics: [CONTENT_CHANNEL]
                })

                $scope.ethStatus =
                  "connected": true

                messageFilter.watch (err,msg) ->
                    if !err and msg
                        console.log( "Message: ",  JSON.stringify( msg ) )
                    if !err and msg?.payload?.root
                        console.log( "Received root hash update: ", msg )
                        refreshProperties( msg.payload.root )
            catch error
                console.log error

            refreshProperties( null )


        $scope.addProperty = ->

            ###
            @name addProperty
            @inner
            ###

            $scope.addPropertyReady = true


        $scope.submitProperty = ->

            ###
            @name submitProperty
            @inner
            ###

            web3.shh.post
                from    : $scope.identity
                topics  : [CONTENT_CHANNEL]
                payload : JSON.stringify
                    from    : $scope.identity
                    content : $scope.propertyContent
                    title   : $scope.propertyTitle

            $scope.propertyContent = null
            $scope.propertyTitle = null


        $scope.addComment = ($event, $newComment) ->

            ###
            @name addComment
            ###

            $event.preventDefault()

            $element = angular.element($event.target)
            $property = $element.closest('.property')

            if $element.hasClass('comment')
                web3.shh.post
                    from    : $scope.identity
                    topics  : [CONTENT_CHANNEL]
                    payload : JSON.stringify
                        from    : $scope.identity
                        parent  : $property.attr( 'id' )
                        content : $newComment

        return

    [
      '$scope',
      '$http',
      HomeController
    ]
)
