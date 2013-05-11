@RegPreciseCtrl = @app.controller 'RegPreciseCtrl', ["$scope", "$http", ($scope, $http)->
  $scope.regpreciseUrl = "/regprecise/index.json"
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
 
  $scope.regpreciseRequests = []

  $scope.regulonListOfNames = []

  $scope.regpreciseRequestAllRegulonsHeaders = []
  $scope.regpreciseRequestSiteByRegulonHeaders = []
  $scope.regpreciseRequestGeneByRegulonHeaders = []
  
  regpreciseRequest = ->
    $scope.loading = true
    # Create the request for the RegPrecise Service
    $http.post($scope.regpreciseUrl, {
        "data": $scope.regpreciseRequestQuery
      })
      .success (data, status)->
        $scope.regpreciseRequestStatus = status
        $scope.regpreciseRequestResponse = data
        $scope.loading = false
      .error (data, status)->
        $scope.regpreciseRequestResponse = data || "Request Failed!"
        $scope.regpreciseRequestStatus = status
        $scope.loading = false

  $scope.setTableHeaders= (type, d)->
    keys = Object.keys d
    
    switch type
      when 'alldata' then foo = $scope.regpreciseRequestAllRegulonsHeaders = keys
      when 'genes' then foo = $scope.regpreciseRequestGeneByRegulonHeaders = keys
      when 'sites' then foo = $scope.regpreciseRequestSiteByRegulonHeaders = keys

    return

  $scope.ww_chartClick = ->
    $scope.regpreciseRequestQuery.type = "wagon_wheel_chart"
    regpreciseRequest().then((d)->
      if d.status is 200 then $scope.child_genes_for_chart = d.data.chart_data)

  $scope.regulogClick = (e)->
    $scope.regpreciseRequestQuery.type = "regulons_by_regulog"
    regpreciseRequest().then((d)->
      for regulon in d.data.regulon
        $scope.regulonListOfNames.push regulon.genomeName
        
      if d.status is 200 then $scope.regpreciseRequestRegulons = d.data.regulon)

  $scope.regulonClick = (e)->
    $scope.regpreciseRequestQuery.type = "regulon_by_id"
    regpreciseRequest().then((d)->
      if d.status is 200
        $scope.regulonListOfNames = []
        $scope.genome = d.data.genomeName
        $scope.TFname = d.data.regulatorName
        $scope.regpreciseRequestRegulons = [d.data])

  $scope.getallClick = (e)->
    $scope.regpreciseRequestQuery.type = "get_all"
    regpreciseRequest().then((d)->
      if d.status is 200
        $scope.setTableHeaders 'alldata', d.data.genomeStat[0]
        $scope.regpreciseRequestAllRegulons = d.data.genomeStat)

  $scope.genesClick = (e)->
    $scope.regpreciseRequestQuery.type = "genes_by_regulon"
    regpreciseRequest().then((d)->

      if $scope.TFname is null
        $scope.regulonClick()

      if d.status is 200
        $scope.setTableHeaders 'genes', d.data.gene[0]
        $scope.regpreciseRequestGeneByRegulon = d.data.gene

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
      if d.status is 200
        $scope.setTableHeaders 'sites', d.data.site[0]
        $scope.regpreciseRequestSiteByRegulon = d.data.site)
]

