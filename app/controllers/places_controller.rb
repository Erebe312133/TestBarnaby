class PlacesController < ApplicationController

    def search
        if params[:query].blank?
            render json: {errors:'error'}, status: 401
            return
        end
        @client = GooglePlaces::Client.new("AIzaSyBYxH6hZs7QxFzDxSwcHBh7LCx-JUFkgHI")
        @client.spots_by_query(params[:query])
        render json: {place: @client.spots_by_query(params[:query])}, status: 201
    end

end