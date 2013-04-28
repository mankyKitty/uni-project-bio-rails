class ChatterController < ApplicationController
  respond_to :json

  def index

    path = get_path params[:data]

    @resp = request_data path

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

    require 'open-uri'

    regprecise_url = "http://regprecise.lbl.gov/Services/rest/#{args}"

    logger.debug regprecise_url

    uri = URI.parse regprecise_url
    uri.open

    response = uri.read
  end
end
