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
            url: URI.escape("https://maps.googleapis.com/maps/api/place/autocomplete/json?input=#{params[:q]}&key=AIzaSyBYxH6hZs7QxFzDxSwcHBh7LCx-JUFkgHI")
        )
        json = JSON.parse response
        response = RestClient::Request.execute(
            method: :get,
            url: URI.escape("https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=#{json['predictions'][0]['description']}&inputtype=textquery&fields=photos,formatted_address,name,rating,opening_hours,geometry&key=AIzaSyBYxH6hZs7QxFzDxSwcHBh7LCx-JUFkgHI")
        )
        json = JSON.parse response

        render json: {google_places: json['candidates']}, status: 201
    end

end