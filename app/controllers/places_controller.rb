class PlacesController < ApplicationController

    def search
        if params[:id].blank?
            render json: {'error'}, status: 401
        end
        render json: {'place': params[id]}, status: 201
    end

end