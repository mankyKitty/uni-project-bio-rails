@RegPreciseCtrl = @app.controller 'RegPreciseCtrl', ["$scope", "$http", ($scope, $http)->
  $scope.regpreciseUrl = "/chatter/index.json"
  # Results from single regulon ID query
  $scope.regulonID = []

  $scope.regpreciseRequest = {
    regulonID: "",
    regulogID: ""
  }

  $scope.child_genes_for_chart = []

  $scope.genome = "Request A Regulon!"
  $scope.TFname = "Undefined"

  $scope.regpreciseRequestQuery = {
    "type": "",
    "info" : $scope.regpreciseRequest
  }

  regpreciseRequest = ->
    # Create the request for the RegPrecise Service
    $http.post($scope.regpreciseUrl, {
        "data": $scope.regpreciseRequestQuery
      })
      .success (data, status)->
        $scope.regpreciseRequestStatus = status
        $scope.regpreciseRequestResponse = data
      .error (data, status)->
        $scope.regpreciseRequestResponse = data || "Request Failed!"
        $scope.regpreciseRequestStatus = status

  $scope.regulogClick = (e)->
    $scope.regpreciseRequestQuery.type = "regulons_by_regulog"
    regpreciseRequest().then((d)->
      if d.status is 200 then $scope.regpreciseRequestRegulons = d.data)

  $scope.regulonClick = (e)->
    $scope.regpreciseRequestQuery.type = "regulon_by_id"
    regpreciseRequest().then((d)->
      if d.status is 200
        $scope.genome = d.data.genomeName
        $scope.TFname = d.data.regulatorName
        $scope.regpreciseRequestSingleRegulon = d.data)

  $scope.getallClick = (e)->
    $scope.regpreciseRequestQuery.type = "get_all"
    regpreciseRequest().then((d)->
      if d.status is 200 then $scope.regpreciseRequestAllRegulons = d.data.genomeStat)

  $scope.genesClick = (e)->
    $scope.regpreciseRequestQuery.type = "genes_by_regulon"
    regpreciseRequest().then((d)->

      if $scope.TFname is null
        $scope.regulonClick()

      if d.status is 200 then $scope.regpreciseRequestGeneByRegulon = d.data.gene

      angular.copy($scope.regpreciseRequestGeneByRegulon, $scope.child_genes_for_chart)

      wData = {
        Genome: $scope.genome,
        TFname: $scope.TFname,
        children: $scope.child_genes_for_chart
      }
      drawAWagonWheelFromWheelData(wData, true, "#chart"))

  $scope.sitesClick = (e)->
    $scope.regpreciseRequestQuery.type = "sites_by_regulon"
    regpreciseRequest().then((d)->
      if d.status is 200 then $scope.regpreciseRequestSiteByRegulon = d.data.site)
]
