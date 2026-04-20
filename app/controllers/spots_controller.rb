class SpotsController < ApplicationController
  include ApiAuthenticatable

  skip_before_action :authenticate_user!, only: [ :index, :api_index, :api_show, :api_create ]
  skip_before_action :verify_authenticity_token, only: [ :api_index, :api_show, :api_create ]
  before_action :authenticate_api_request!, only: [ :api_index, :api_show, :api_create ]
  before_action :set_spot, only: [ :show, :api_show, :update, :destroy ]
  before_action :require_permission, only: [ :edit, :update, :destroy ]

  # GET /spots
  def index
    # TODO: Add Pagination
    @spots =
      if params[:spot_type]
        Spot.where(spot_type: params[:spot_type])
      else
        Spot.includes(:user, :ratings).all.sort_by(&:average_rating).reverse
      end
  end

  # GET /api/spots
  def api_index
    if params[:spot_type]
      @spots = Spot.where(spot_type: params[:spot_type])
    else
      @spots = Spot.all.includes(:user, :ratings)
    end
    render json: @spots.as_json(methods: [ :average_rating ])
  end

  # GET /spots/:id
  def show
    @spot
  end

  # GET /api/spots/:id
  def api_show
    @spot
    render json: @spot.as_json(methods: [ :average_rating ])
  end

  # POST /api/spots
  def api_create
    @spot = api_user.spots.new(api_spot_params)

    if @spot.save
      render json: @spot.as_json(methods: [ :average_rating ]), status: :created
    else
      render json: {
        error: "Validation failed",
        errors: @spot.errors.as_json,
        required_fields: {
          name: "string",
          description: "string",
          spot_type: "one of: #{Spot::VALID_SPOT_TYPES.join(', ')}",
          latitude: "decimal",
          longitude: "decimal"
        },
        optional_fields: {
          web_link: "string (URL)"
        }
      }, status: :unprocessable_entity
    end
  end

  # GET /spots/new
  def new
    @spot = Spot.new
    if params["latitude"].present? && params["longitude"].present?
      @spot.latitude = params["latitude"]
      @spot.longitude = params["longitude"]
    end
  end

  # POST /spots
  def create
    if (@spot = current_user.spots.create!(spot_params))
      redirect_to @spot
    else
      render "new"
    end
  end

  # GET /spots/:id/edit
  def edit
    @spot = Spot.find(params[:id])
  end

  # PUT /spots/:id
  def update
    @spot = Spot.find(params[:id])

    if @spot.update(spot_params)
      redirect_to @spot
    else
      render "edit"
    end
  end

  # DELETE /spots/:id
  def destroy
    @spot.destroy
    redirect_to spots_path
  end

  private

  def require_permission
    unless current_user == Spot.find(params[:id]).user || current_user.admin?
      redirect_to spot_path
    end
  end

  def spot_params
    # whitelist params
    params.require(:spot).permit(:name, :spot_type, :description, :latitude, :longitude, :web_link)
  end

  def api_spot_params
    params.permit(:name, :spot_type, :description, :latitude, :longitude, :web_link)
  end

  def set_spot
    @spot = Spot.find(params[:id])
  end
end
