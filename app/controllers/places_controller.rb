require 'rest-client'

class PlacesController < ApplicationController

    def search
        if params[:q].blank?
            render json: {errors:'error'}, status: 401
            return
        end
        @barnaby_places = Place.by_matching_name(params[:q])
        get_place_with_google
        render json: {google_places: @google_places, barnaby_places: @barnaby_places}, status: 201
    end

private

    def get_place_with_google
        response = RestClient::Request.execute(
            method: :get,
            url: URI.escape("https://maps.googleapis.com/maps/api/place/autocomplete/json?input=#{params[:q]}&key=AIzaSyBYxH6hZs7QxFzDxSwcHBh7LCx-JUFkgHI")
        )
        json = JSON.parse response
        @google_places = []
        json['predictions'][0..4].each do |row|
            response_place = RestClient::Request.execute(
                method: :get,
                url: URI.escape("https://maps.googleapis.com/maps/api/place/details/json?key=AIzaSyBYxH6hZs7QxFzDxSwcHBh7LCx-JUFkgHI&placeid=#{row['place_id']}&fields=alt_id,formatted_address,geometry,icon,id,name,permanently_closed,place_id,plus_code,scope,type,url,user_ratings_total,utc_offset,vicinity")
            )
            json_place = JSON.parse response_place
            logger.debug "here" if json_place.key? 'geometry'
            get_bar_in_place json_place['result']['geometry']['location'] if json_place.key?('result') && json_place['result']['types'].include?('locality')
            @google_places << json_place['result'] if json_place.key?('result') && json_place['result']['types'].include?('bar')
        end
    end

    def get_bar_in_place(coordinate)
        response = RestClient::Request.execute(
            method: :get,
            url: URI.escape("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{coordinate['lat']},#{coordinate['lng']}&radius=1500&type=bar&key=AIzaSyBYxH6hZs7QxFzDxSwcHBh7LCx-JUFkgHI")
        )
        json = JSON.parse response
        json['results'][0..4].each do |row|
            response_place = RestClient::Request.execute(
                method: :get,
                url: URI.escape("https://maps.googleapis.com/maps/api/place/details/json?key=AIzaSyBYxH6hZs7QxFzDxSwcHBh7LCx-JUFkgHI&placeid=#{row['place_id']}&fields=alt_id,formatted_address,geometry,icon,id,name,permanently_closed,place_id,plus_code,scope,type,url,user_ratings_total,utc_offset,vicinity")
            )
            json_place = JSON.parse response_place
            @google_places << json_place['result'] if json_place.key?('result') && json_place['result']['types'].include?('bar')
        end
    end

end