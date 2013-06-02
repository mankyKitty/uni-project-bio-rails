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

  $scope.regpreciseRequestSiteByRegulonHeaders = []
  $scope.regpreciseRequestGeneByRegulonHeaders = []

  $scope.regpreciseSiteData = []
  $scope.regpreciseGeneData = []

  $scope.regulonDataPresent = false
  $scope.siteDataPresent = false
  $scope.geneDataPresent = false

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
        $scope.regpreciseRequestStatus = status
        $scope.regpreciseRequestResponse = data || "Request Failed!"
        $scope.loading = false

  updateNGshowVars = ->
    $scope.regulonDataPresent = $scope.regpreciseRequestRegulons.length > 0
    $scope.geneDataPresent = $scope.regpreciseGeneData.length > 0
    $scope.siteDataPresent = $scope.regpreciseSiteData.length > 0

  requestOk = (d)->
    d.status is 200

  setTableHeaders= (type, d)->
    keys = Object.keys d

    switch type
      when 'genes' then $scope.regpreciseRequestGeneByRegulonHeaders = keys
      when 'sites' then $scope.regpreciseRequestSiteByRegulonHeaders = keys

  processResults = (type, data)->
    switch type
      when "regulon_by_id" then chartRegulon(data)
      when "genes_by_regulon" then genesByRegulon(data)
      when "sites_by_regulon" then sitesByRegulon(data)

  $scope.queryRegPrecise = (queryType)->
    $scope.regpreciseRequestQuery.type = queryType
    regpreciseRequest().then((d)->
      if requestOk(d) then processResults(queryType, d))

  chartRegulon = (d)->
    $scope.regulonListOfNames = []
    $scope.genome = d.data.genomeName
    $scope.TFname = d.data.regulatorName
    $scope.regpreciseRequestRegulons = [d.data]

    # Trigger our gene data request
    $scope.queryRegPrecise("genes_by_regulon")
    # Trigger our site data request
    $scope.queryRegPrecise("sites_by_regulon")

  genesByRegulon = (d)->
    $scope.regpreciseGeneData = d.data.gene
    setTableHeaders 'genes', $scope.regpreciseGeneData[0]
    $scope.regpreciseRequestGeneByRegulon = $scope.regpreciseGeneData
    # Update our GUI to display the newly retrieved data
    updateNGshowVars()

    $scope.child_genes_for_chart = []

    angular.copy($scope.regpreciseRequestGeneByRegulon, $scope.child_genes_for_chart)

    wData = {
      Genome: $scope.genome,
      TFname: $scope.TFname,
      children: $scope.child_genes_for_chart
    }
    if wData.children.length > 0 then drawAWagonWheelFromWheelData(wData, true, "#chart", true)

  sitesByRegulon = (d)->
    $scope.regpreciseSiteData = d.data.site
    setTableHeaders 'sites', $scope.regpreciseSiteData[0]
    $scope.regpreciseRequestSiteByRegulon = $scope.regpreciseSiteData
    # Update the GUI to show the new data
    updateNGshowVars()

  $scope.regulogClick = ()->
    $scope.regpreciseRequestQuery.type = "regulons_by_regulog"
    regpreciseRequest().then((d)->
      if requestOk(d)
        for regulon in d.data.regulon
          $scope.regulonListOfNames.push regulon.genomeName

        if requestOk(d) then $scope.regpreciseRequestRegulons = d.data.regulon)

]

