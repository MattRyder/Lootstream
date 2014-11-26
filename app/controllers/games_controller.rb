class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy, :game_info]

  # GET /games
  def index
    @games = Game.all
  end

  # GET /games/1
  def show
  end

  # GET /games/new
  def new
    @game_types = Game.descendants.map(&:name) rescue []
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
    @game_types = Game.descendants.map(&:name) rescue []
  end

  # POST /games
  def create
    @game = create_object

    if @game.save
      redirect_to games_path, notice: 'Game was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /games/1
  def update
    if @game.update(game_params)
      redirect_to @game, notice: 'Game was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /games/1
  def destroy
    @game.destroy
    redirect_to games_url, notice: 'Game was successfully destroyed.'
  end

  # GET /games/1/info
  def game_info
    respond_to do |format|
      format.json { render json: @game }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    def create_object
      game_type = game_params[:type]
      if Game.types.include? game_type
        return game_type.constantize.new
      else
        return Game.new
      end
    end

    # Only allow a trusted parameter "white list" through.
    def game_params
      params.require(:game).permit(:name, :max_options, :game_type, :description)
    end
end
