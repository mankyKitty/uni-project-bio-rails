class RegpreciseController < ApplicationController
  respond_to :json

  def index
    # Get our path arguments based on request type.
    path = get_path params[:data]
    # Query the service.
    @resp = request_data path
    # Send our response as JSON to the client App.
    respond_to do |format|
      format.json { render json: @resp }
    end
  end

  def get_path(req)
    # Get some oft used data from the request
    regulonId = req[:info][:regulonID]
    regulogId = req[:info][:regulogID]

    path = case req[:type]
      # Request a single regulon by its ID
      when "regulon_by_id" then "regulon?regulonId=#{regulonId}"
      # Request the Sites information for a specific Regulon
      when "sites_by_regulon" then "sites?regulonId=#{regulonId}"
      # Request the Gene data for a specific Regulon
      when "genes_by_regulon" then "genes?regulonId=#{regulonId}"
      # Request Regulons by their shared regulog ID
      when "regulons_by_regulog" then "regulons?regulogId=#{regulogId}"
      # Request all genome statistical data
      when "get_all" then "genomeStats"
    end

    path
  end

  def request_data(args)
    # Include the Package we need for uri requests.
    require 'open-uri'
    # This is the base RegPrecise Services URL, all requests start here.
    regprecise_url = "http://regprecise.lbl.gov/Services/rest/#{args}"
    # Ensure our URI is as the library expects and nothing creepy has snuck in.
    uri = URI.parse regprecise_url
    # Open a connection and read the data
    uri.open
    # Return our response to the front end application.
    response = uri.read
  end

end
