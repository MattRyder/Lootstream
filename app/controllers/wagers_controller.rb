class WagersController < ApplicationController
  before_action :set_channel, only: [
    :index, :place_bet, :distribute_winnings, :create, :show, :active_wager]

  before_action :set_wager, only: [
    :show, :place_bet, :edit, :update, :destroy, :distribute_winnings
  ]

  # GET /wagers
  # GET /wagers.json
  def index
    @active_wager = Wager.where(channel: @channel, active: true).last
    @last_wagers = Wager.where(channel: @channel, active: false).last(5)
  end

  def place_bet
    result = { success: false, error_message: "Can't find that wager option!"}
    option = @wager.wager_options.find(params[:wager_option_id])
    if option.present?
      result = @wager.place_bet(params[:wager_option_id], current_user, params[:amount])
    end
    render json: result
  end

  def distribute_winnings
    result = { success: false, error_message: "Can't find that wager option!"}
    
    option = @wager.wager_options.find(params[:wager_option_id])
    if option.present?
      result = { success: true, status: option.wager.set_winner(option) } 
    end

    respond_to do |format|
      format.html { redirect_to channel_wagers_path, notice: "Winner has been set, all bets have been paid out!"}
      format.json { render json: result }
    end
  end

  def process_realtime
    response = {}
    
    if @wager.present?
      if @wager.active
        odds_data = []
        @wager.wager_options.each do |option|
          odds_data << { id: option.id, value: option.calculate_odds }
        end
        response[:odds] = odds_data.as_json
      elsif params[:uid].present?
        transaction = @wager.user_transaction(params[:uid].to_i)
        if transaction
          response[:wager_state] = {
            state: transaction.wager_option.won ? "won" : "lost",
            winopt: @wager.winning_option,
            balance: current_user.channel_balance(@wager.channel).display_value
          }
        end
      end
    end

    render json: response
  end

  def new_wager_setup
    @wager = Wager.new
    2.times{ @wager.wager_options.build }

    game = Game.find(params[:game_id])
    raise_404 if !game.present?

    @game_name = game.name
    @max_options = game.max_options
    @wager.game = game

    render "wagers/game_forms/#{game.partial_name}"
  end

  # GET /wagers/1
  # GET /wagers/1.json
  def show
    @summary = @wager.transaction_data || []
  end

  # GET /wagers/new
  def new
    @games = Game.all
  end

  # GET /wagers/1/edit
  def edit
  end

  # POST /wagers
  # POST /wagers.json
  def create
    @games = Game.all
    @wager = Wager.new(wager_params)
    @wager.channel = @channel

    respond_to do |format|
      if @wager.save
        format.html { redirect_to @channel, notice: 'Wager was successfully created.' }
        format.json { render @wager, status: :created }
      else
        format.html { render "wagers/game_forms/#{@wager.game.partial_name}" }
        format.json { render json: @wager.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wagers/1
  # PATCH/PUT /wagers/1.json
  def update
    respond_to do |format|
      if @wager.update(wager_params)
        format.html { redirect_to channel_wager_path(@channel, @wager), notice: 'Wager was successfully updated.' }
        format.json { render :show, status: :ok, location: @wager }
      else
        format.html { render :edit }
        format.json { render json: @wager.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wagers/1
  # DELETE /wagers/1.json
  def destroy
    @wager.suspend
    respond_to do |format|
      format.html { redirect_to channel_url(@wager.channel), notice: 'Wager was successfully suspended.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wager
      @wager = @channel.wagers.find(params[:id])
    end

    def set_channel
      @channel = Channel.find_by(name: params[:channel_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wager_params
      params.require(:wager).permit(:game_id, :question, :min_amount, :max_amount,
        wager_options_attributes: [:id, :text, :_destroy])
    end
end
