require 'rest-client'

class PlacesController < ApplicationController

    def search
        Rails.logger.info "1"
        if params[:q].blank?
            render json: {errors:'error'}, status: 401
            return
        end
        response = RestClient::Request.execute(
            method: :get,
            url: URI.escape("https://maps.googleapis.com/maps/api/place/autocomplete/json?input=#{params[:q]}&key=GOOGLE_API_KEY")
        )
        json = JSON.parse response

        places = Place.by_matching_name(params[:q])

        render json: {google_places: json['predictions'], barnaby_places: places}, status: 201
    end

end