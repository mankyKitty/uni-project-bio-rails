class RegpreciseController < ApplicationController
  respond_to :html

  def regprecise
  	require 'open-uri'

    regprecise_url = "http://regprecise.lbl.gov/Services/rest/genomeStats"

    uri = URI.parse(regprecise_url)
    uri.open

    response = uri.read

    response_with response
  end

end
