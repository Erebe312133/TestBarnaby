require 'rest-client'

class PlacesController < ApplicationController

    def search
        if params[:q].blank?
            render json: {errors:'error'}, status: 401
            return
        end
        @barnaby_places = []
        Place.by_matching_name(params[:q]).each { |place| @barnaby_places << place}
        get_place_with_google
        render json: {google_places: @google_places, barnaby_places: @barnaby_places}, status: 201
    end

private

    def get_place_with_google
        response = RestClient::Request.execute(
            method: :get,
            url: URI.escape("https://maps.googleapis.com/maps/api/place/autocomplete/json?input=#{params[:q]}&key=#{GOOGLE_API_KEY}")
        )
        json = JSON.parse response
        @google_places = []
        json['predictions'][0..4].each do |row|
            response_place = RestClient::Request.execute(
                method: :get,
                url: URI.escape("https://maps.googleapis.com/maps/api/place/details/json?key=#{GOOGLE_API_KEY}&placeid=#{row['place_id']}&fields=alt_id,formatted_address,geometry,icon,id,name,permanently_closed,place_id,plus_code,scope,type,url,user_ratings_total,utc_offset,vicinity")
            )
            json_place = JSON.parse response_place
            get_bar_in_place json_place['result']['geometry'] if json_place.key?('result') && json_place['result']['types'].include?('locality')
            @google_places << json_place['result'] if json_place.key?('result') && json_place['result']['types'].include?('bar')
        end
    end

    def get_bar_in_place(coordinate)
        response = RestClient::Request.execute(
            method: :get,
            url: URI.escape("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{coordinate['location']['lat']},#{coordinate['location']['lng']}&radius=1500&type=bar&key=#{GOOGLE_API_KEY}")
        )
        json = JSON.parse response
        json['results'][0..4].each do |row|
            response_place = RestClient::Request.execute(
                method: :get,
                url: URI.escape("https://maps.googleapis.com/maps/api/place/details/json?key=#{GOOGLE_API_KEY}&placeid=#{row['place_id']}&fields=alt_id,formatted_address,geometry,icon,id,name,permanently_closed,place_id,plus_code,scope,type,url,user_ratings_total,utc_offset,vicinity")
            )
            json_place = JSON.parse response_place
            @google_places << json_place['result'] if json_place.key?('result') && json_place['result']['types'].include?('bar')
        end
        coordinate['viewport']['southwest'] = [coordinate['viewport']['southwest']['lat'], coordinate['viewport']['southwest']['lng']]
        coordinate['viewport']['northeast'] = [coordinate['viewport']['northeast']['lat'], coordinate['viewport']['northeast']['lng']]
        coordinate['location'] = [coordinate['location']['lat'], coordinate['location']['lng']]
        Coordinate.in_bounds([coordinate['viewport']['southwest'], coordinate['viewport']['northeast']], :origin => coordinate['location']).each { |coord| @barnaby_places << coord.place }
    end

end