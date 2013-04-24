class ChatterController < ApplicationController
  respond_to :json

  def index
    response = request_data
    respond_with response
  end

  def request_data(args = "")
    require 'open-uri'

    regprecise_url = "http://regprecise.lbl.gov/Services/rest/genomeStats"

    uri = URI.parse(regprecise_url)
    uri.open

    response = uri.read
  end
end
