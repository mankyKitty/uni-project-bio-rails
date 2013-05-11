class RegpreciseController < ApplicationController
  respond_to :json

  def index

    path = get_path params[:data]

    # Charts are a special case and we need to handle them separately.
    if params[:data][:type] == 'wagon_wheel_chart'
      # Get Regulon data
      params[:data][:type] = "regulon_by_id"
      regulon = request_data get_path params[:data]
      # Get Gene data
      params[:data][:type] = "genes_by_regulon"
      genes = request_data get_path params[:data]
      # Get Site data
      params[:data][:type] = "sites_by_regulon"
      sites = request_data get_path params[:data]
      # Attach Site data to Gene based on locus tag
      chart_data = []

      wheel = {
        "Genome" => regulon.genomeName,
        "TF" => regulon.regulatorName,
        "children" => []
      }
              
      genes[:gene].each do |gene|
        site = sites.select do |s|
        end

        wheel[:children].push << gene
      end
      # Return
    else
      @resp = request_data path
    end

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
