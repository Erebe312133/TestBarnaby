require 'rest-client'

class PlacesController < ApplicationController

    def search
        if params[:q].blank?
            render json: {errors:'error'}, status: 401
            return
        end
        response = RestClient::Request.execute(
            method: :get,
            url: URI.escape("https://maps.googleapis.com/maps/api/place/autocomplete/json?input=#{params[:q]}&key=AIzaSyBYxH6hZs7QxFzDxSwcHBh7LCx-JUFkgHI")
        )
        json = JSON.parse response
        google_places = []
        json['predictions'].each do |row|
            response_place = RestClient::Request.execute(
                method: :get,
                url: URI.escape("https://maps.googleapis.com/maps/api/place/details/json?key=AIzaSyBYxH6hZs7QxFzDxSwcHBh7LCx-JUFkgHI&placeid=#{row['place_id']}&fields=alt_id,formatted_address,geometry,icon,id,name,permanently_closed,photo,place_id,plus_code,scope,type,url,user_ratings_total,utc_offset,vicinity")
            )
            json_place = JSON.parse response_place
            google_places << json_place['result'] if json_place.key?('result') && json_place['result']['types'].include?('bar')
        end
        places = Place.by_matching_name(params[:q])

        render json: {google_places: google_places, barnaby_places: places}, status: 201
    end

end